require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class Attributes
      class FieldsTest < ActiveSupport::TestCase
        class Post < ::Model; end
        class Author < ::Model; end
        class Comment < ::Model; end

        class PostSerializer < ActiveModel::Serializer
          attributes :title, :body
          belongs_to :author
          has_many :comments
        end

        class AuthorSerializer < ActiveModel::Serializer
          attributes :name, :birthday
        end

        class CommentSerializer < ActiveModel::Serializer
          attributes :body
          belongs_to :author
        end

        def setup
          @author = Author.new(id: 1, name: 'Nick', birthday: '06.02.1988')
          @comment1 = Comment.new(id: 7, body: 'cool', author: @author)
          @comment2 = Comment.new(id: 12, body: 'awesome', author: @author)
          @post = Post.new(id: 1337, title: 'Title 1', body: 'Body 1',
                           author: @author, comments: [@comment1, @comment2])
          @comment1.post = @post
          @comment2.post = @post
        end

        def test_fields_attributes
          fields = { posts: [:title] }
          hash = serializable(@post, adapter: :attributes, fields: fields).serializable_hash
          expected = {
            title: 'Title 1'
          }

          assert_equal(expected, hash)
        end

        def test_fields_relationships
          fields = { posts: [:author] }
          hash = serializable(@post, adapter: :attributes, fields: fields).serializable_hash
          expected = {
            author: {
              name: 'Nick',
              birthday: '06.02.1988'
            }
          }

          assert_equal(expected, hash)
        end

        def test_fields_included
          fields = { posts: [:title, :author], comments: [:body] }
          hash = serializable(@post, adapter: :attributes, fields: fields, include: 'comments').serializable_hash
          expected = [
            title: 'Title 1',
            author: {
              name: 'Nick',
              birthday: '06.02.1988'
            },
            comments: [
              {
                id: '7',
                body: 'cool'
              }, {
                id: '12',
                body: 'awesome'
              }
            ]
          ]

          assert_equal(expected, hash)
        end
      end
    end
  end
end
