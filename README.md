这个工程主要是评论功能的原型

工程中的 Book 模型，只是为了演示用，整合时，不需要搬过去

-----------------------------------------------
最后上线的系统中会有很多模型可以评论，这些评论都用该模型

所以评论模型用多态外键（Rails的一个特性，通俗的说，就是联合外键）

下边是一个多态的例子

```ruby
# 模型上需要两个字段
create_table :comments do |t|
  t.integer     :model_id
  t.string      :model_type
end

class Comment < ActiveRecord::Base
  belongs_to :model, :polymorphic => true
end

class Book < ActiveRecord::Base
  has_many :comments,:as=>:model
end
···

