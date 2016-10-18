# 因为AgentsGroups的many写法太复杂，所以用Ag，这样用： has_many :ags。不过用ag这个名字不容易望文生义, 最好用Agentgroup作为class name
class Ag < AgentsGroups
end
