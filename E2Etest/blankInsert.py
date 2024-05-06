
from PIL import Image
import os

def create_blank_image_like(input_image_path):
   
    input_image = Image.open(input_image_path)
    width, height = input_image.size
    blank_image = Image.new("RGB", (width, height), "white")
    return blank_image

folder_path = './'

# search 100,200
for filename in ['frames_100.png', 'frames_200.png']:
    input_image_path = os.path.join(folder_path, filename)   
    blank_image = create_blank_image_like(input_image_path)
    os.remove(input_image_path)
    blank_image.save(input_image_path)

print("Successful completion !")
