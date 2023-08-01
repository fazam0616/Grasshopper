from PIL import Image
from numpy import asarray

img = asarray(Image.open("Background.bmp"))
nums = []

for row in img:
    for column in row:
        color="0x"
        for val in column:
            s = hex(val)[2:]
            if (len(s) == 1):
                color+="0"
            color+=s
        #print(color)
        nums.append(color)

f=open("out.txt","w")
for col in nums:
    f.write(col+", ")
f.close()
