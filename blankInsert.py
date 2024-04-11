from PIL import Image
import os

def create_blank_image_like(input_image_path):
    # 打开输入图片
    input_image = Image.open(input_image_path)
    
    # 获取输入图片的宽度和高度
    width, height = input_image.size
    
    # 创建一个与输入图片相同大小的空白图像，背景为白色
    blank_image = Image.new("RGB", (width, height), "white")
    
    return blank_image

# 指定文件夹路径
folder_path = './'

# 找到并处理frames_0100.png和frames_0200.png
for filename in ['frames_0100.png', 'frames_0200.png']:
    input_image_path = os.path.join(folder_path, filename)
    # 创建空白图像
    blank_image = create_blank_image_like(input_image_path)
    # 删除原图像
    os.remove(input_image_path)
    # 保存空白图像为原图像名称
    blank_image.save(input_image_path)

print("处理完成！")