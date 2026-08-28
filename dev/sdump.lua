function alf1(a) print("lf1: ", a) end
print("alf1===", alf1)
print("alf2===", string.dump(alf1))
return string.dump(function(dd) print(dd) end)
