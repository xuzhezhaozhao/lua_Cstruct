require "cs"

local function test(exp, caseN)
	assert(exp, string.format("case #%d failed\n", caseN))
	print(string.format("case #%d passed", caseN))
end

local student = {id="number", name="string", score="number", good="bool"}
local school = {name="string", id="number",  pub="number", student=student, http="number"}
local size = 20
local length = 57
local st = cs.create(school, size)

test(st._n_ == size, 1)
print(st._length_)
test(st._length_ == length, 2)
test(st._data_ ~= nil, 3)
test(st._root_ == st, 4)

test(type(st.name) == "table", 5)
test(type(st.id) == "table", 5)
test(type(st.pub) == "table", 6)
test(type(st.student) == "table", 7)
test(type(st.http) == "table", 8)

test(type(st.student.id) == "table", 9)
test(type(st.student.name) == "table", 10)
test(type(st.student.score) == "table", 11)

test(st.name._root_ == st, 12)
test(st.id._root_ == st, 13)
test(st.pub._root_ == st, 14)
test(st.student._root_ == st, 15)
test(st.http._root_ == st, 16)

test(st.student.id._root_ == st, 17)
test(st.student.name._root_ == st, 18)
test(st.student.score._root_ == st, 19)

print("\nset & get test...")
test(cs.get(2, st.name) == nil, 20)
test(cs.get(2, st.id) == 0, 21)
test(cs.get(12, st.student) == nil, 22)
test(cs.get(19, st.student.name) == nil, 23)
test(cs.get(19, st.student.id) == 0, 24)

cs.set(2, st.name, "zhangshuzhongxue")
test(cs.get(2, st.name) == "zhangshuzhongxue", 25)
cs.set(2, st.name, "lingchuanzhongxue")
test(cs.get(2, st.name) == "lingchuanzhongxue", 26)
cs.set(5, st.id, 200)
test(cs.get(5, st.id) == 200, 27)
cs.set(15, st.pub, 100)
test(cs.get(15, st.pub) == 100, 28)
cs.set(15, st.http, 50)
test(cs.get(15, st.http) == 50, 29)

cs.set(10, st.student.id, 2014210863)
test(cs.get(10, st.student.id) == 2014210863, 30)
cs.set(10, st.student.name, "xuzhezhao")
test(cs.get(10, st.student.name) == "xuzhezhao", 31)
cs.set(10, st.student.name, "zhangsan")
test(cs.get(10, st.student.name) == "zhangsan", 32)
cs.set(11, st.student.name, "lisi")
test(cs.get(11, st.student.name) == "lisi", 33)
test(cs.get(10, st.student.name) == "zhangsan", 34)

cs.set(11, st.student.score, 99)
test(cs.get(11, st.student.score) == 99, 35)
test(cs.get(12, st.student.score) == 0, 36)
cs.set(12, st.student.score, 98)
test(cs.get(12, st.student.score) == 98, 37)

local stud = st.student
test(stud.score == st.student.score, 38)
cs.set(13, stud.score, 97)
test(cs.get(13, stud.score) == 97, 39)
test(cs.get(13, st.student.score) == 97, 40)

cs.set(1, st.name, "zhezhao")
test(st.name[1] == "zhezhao", 41)

st.name[2] = "wusong"
test(st.name[2] == "wusong", 42)

st.student.id[12] = 1001
test(st.student.id[12] == 1001, 43)

st.student.id[20] = 2002
test(st._n_ == 20, 45)
test(st.student.id._root_._length_ == st._length_, 46)
test(st.student.id[20] == 2002, 47)

st.student.id[21] = 2001
test(st._n_ == 21, 48)
test(st.student.id[21] == 2001, 49)


cs.free(st)
test(st._data_ == nil, 50)
