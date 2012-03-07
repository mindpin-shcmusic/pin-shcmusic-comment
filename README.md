这是一个简单的小工程，用来方便团队进行原型开发。

使用步骤：

1. bundle install
   安装依赖的gem
   
2. 修改 config/database.yml
   下面的 database 配置信息
   然后
   rake db:create
   rake db:migrate
   
----------------------------------------------------

MINDPIN TEAM rails 代码规范（v0.02）

author: fushang318, ben7th

为了便于北京上海两地开发的沟通方便，特拟定以下代码规范：

基本编码风格部分
===============

1 变量名和方法名命名，全部使用小写火车式，不使用骆驼式。这也是Ruby社区的习惯。

　（虽然JAVA社区不是这种风格，但是我们团队写java时也会遵循这一习惯。）

举例：

```ruby
# 变量名
my_book
group_title
users_in_my_group

# 方法名
def played_musics
end

def check_bill(bill)
end
```


2 表示数组的变量，都用复数形式单词结尾，hash变量，都用 _hash 结尾

举例：

```ruby
# 变量名
my_groups
team_members_questions
```


3 Class名（类名），Module名（方法模块名）的命名，全部使用骆驼式，不使用火车式。

举例：

```ruby
# 类名
class User
end

Class VoteResult
end

Class OssFileAdapter
end
```


4 常量的命名，全部使用大写火车式

举例：

```ruby
# 常量名
class Book
  KIND_PUBLIC = '01'
  KIND_PRIVATE = '02'
end
```


5 所有布尔方法（返回 true | false 的方法）。命名时全部在方法末尾带上问号。

  同时，方法名应根据其表达的实际含义，以 has_ , is_ , can_ 等开头。
  
举例：

```ruby
def has_paid?
  # ...
end

def can_play?
  # ...
end

def is_single?
  # ...
end
```


6 判断对象是否为空时，用 if !!xx 或 if !xx.blank? 都可以。

举例：

```ruby
if !!book_author
  # ...
end

if !title.blank?
  # ...
end
```


7 判断值是否相等时，建议 if 1 == xx 这样子，把变量写在后面，不容易因为少写一个 = 而导致错误赋值。

举例：

```ruby
if 7 == weekdays_count
  # ...
end
```


8 变量名命名尽量完整体现其逻辑含义以便于理解，写长一点也无所谓。

一般只会在 block 里面使用简写的变量名
   
举例：

```ruby
my_groups_vip_members
books_with_more_than_three_authors

group_members.map{|m| m.name}
```


9 定义方法参数和传参时，能传对象，就传完整对象。尽量不去传对象上面的某个变量。

举例：

```ruby
def has_paid_by?(user_id)
  # ...
end

# 不如

def has_paid_by?(user)
  user_id = user.id
  # ...
end
```


10 当参数只有一个 user 时，方法名可以命名为，xxx_by(user), xxx_with(user) 等，以便于理解。

举例：

```ruby
def has_paid_by?(user)
  # ...
end

def discuss_with(user)
  # ...
end
```

11 私有方法一般用 _ 开头

举例：

```ruby
def process
  _process_one
  _process_two
end

def _process_one
  # ...
end

def _process_two
  # ...
end
```

12 遍历数组用 each, 不用 for in

举例：

```ruby
  nums = [1,2]
  
  # 用 each
  mums.each{|n|#...}
  
  # 不用 for in
  for n in nums do
    #..
  end
```


模型(MODEL)部分
========

1 模型层，所有表示“创建者”的外键，均命名为 creator_id。

同时声明关联为， 
  
```ruby
belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id
```
  
这样做的目的是，以群组这样模型为例，会有创建者和参与者两个概念，如果创建者使用user声明，而参与者使用users声明，则很容易混淆穿越。

所以一般情况下创建者都统一为creator，也是便于理解。

（除了某些特殊情况下，创建者同时表达其他的逻辑含义，此时具体问题具体分析来命名）



2 所有能直接从模型关联声明而获得的方法，如查询子项，查询count等，一般不再重复定义方法。

举例：

```ruby
  class Team < ActiveRecord::Base
    has_many :members
  end
  
  # 查询 member 数量
  team.members.count
```

3 由于添加了新的逻辑功能模块，而给原有的基础对象A声明的模型关联方法（如User）

  不声明在基础对象A上，以避免对象A的代码无限增加。
  
  可以通过在新逻辑的类里声明内部 module ，让对象A inclued，通过 def self.included(base) 方法，来给对象A增加声明。
  
  module 应命名为 (A的类名)Methods

4 上面提到的所有 (A的类名)Methods 中，应以

base.has_many :xxxs 等 来声明模型关联
  
以 子 module InstanceMethods 来声明实例方法
  
以 子 module ClassMethods 来声明类方法
  
举例：

```ruby
  class User < ActiveRecord::Base
    include Vote::UserMethods
  end
  
  class Vote < ActiveRecord::Base
    module UserMethods
      def self.included(base)
        base.has_many :votes
        base.include InstanceMethods
        base.extend ClassMethods
      end
      
      module InstanceMethods
        def has_vote?
          0 != self.votes.count 
        end
      end
      
      module ClassMethods
        def has_vote_users_count
          # ....
        end
      end
    end
  end
```

5 所有自定义校验方法，命名都以 validate_ 开头。

举例：

```ruby
class Vote < ActiveRecord::Base
  validate :validate_vote_items_count
  def validate_vote_items_count
    errors.add(:base, '限选数目应至少为1项') if self.select_limit < 1
  end
end
```

6 模型中代码，建议按以下顺序排序：

- 本Model的业务逻辑需要引用的module
- 本Model的模型关联声明
- 本Model的校验方法
  - rails 校验方法
  - 自定义的校验方法
- 业务逻辑方法
- 给其他类扩展的方法module

控制器(CONTROLLER)部分
===============

1 controller层，因为用户权限不够而不能执行逻辑时，应 render :status=>401

2 一次创建一对多的关联对象，尽量使用nested_form，以简化 controller 代码

可参考：
http://railscasts.com/episodes/196-nested-model-form-part-1
http://railscasts.com/episodes/197-nested-model-form-part-2

3 Controller 中可以使用 pre_load 的 before_filter，以避免重复写 find_by_id。

举例：

```ruby
  class VotesController < ApplicationController
    before_filter :per_load
    def per_load
      @vote = Vote.find(params[:id]) if params[:id]
    end
    
    def show
      # 直接使用 @vote
    end
    
    def edit
      # 直接使用 @vote
    end
  end
```
