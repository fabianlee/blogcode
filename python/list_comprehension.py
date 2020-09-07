#!/usr/bin/env python
#
# Example of python list comprehension
#
# Supports blog entry: https://fabianlee.org/2020/09/07/python-examples-of-list-comprehension/
#
from pprint import pprint

# array of student records, emulates possible json/yaml data structure
students = [
        { 'name':'amy', 'gpa': 3.9, 'classes': ['biology','science'] },
        { 'name':'bob', 'gpa': 3.7, 'classes': ['biology','english'] },
        { 'name':'dan', 'gpa': 2.5, 'classes': ['biology','english'] }
]
pprint(students)
print("")

# list comprehension - pull out single field (name)
print("all students: {}\n".format([ student['name'] for student in students ]))

# list comprehension - apply sum of field to all records (gpa)
average_gpa = sum(student['gpa'] for student in students) / len(students)
print("Average student GPA={0:.2f}, with student population of {1}\n".format(average_gpa,len(students)))

# list comprehension - pull single field with filter (name given gpa filter)
honors_students = [ student['name'] for student in students if student['gpa']>3.5 ]
print("Honors student list: {}\n".format(honors_students))

# list comprehension - pull two fields with filter (name+gpa given gpa filter)
honors_gpas = [ [student['name'],student['gpa']] for student in students if student['gpa']>3.5 ]
print("Honors student gpa: {}\n".format(honors_gpas))

# list comprehension - pull single field with filter on nested structure (name given classes)
science_students = [ student['name'] for student in students if 'science' in student['classes'] ]
print("Science students: {}\n".format(science_students))

# dict comprehension - create map using fields from list
name_gpa_map = { student['name']:student['gpa'] for student in students }
print("student_gpa map sorted by name: {}".format(sorted(name_gpa_map,key=str.lower)))
print("student_gpa map sorted by gpa: {}".format(sorted(name_gpa_map.values())))


#print("Best grades list")
#for student in sorted(students, reverse=True, key=lambda x: x['gpa']):
#  print("{} gpa={}".format(student['name'],student['gpa']))

#print("Worst grades list")
#for student in sorted(students, key=lambda x: x['gpa']):
#  print("{} gpa={}".format(student['name'],student['gpa']))

