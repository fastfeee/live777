from PIL import Image
import cv2

# 检查 Pillow 是否正常工作
print("Pillow version:", Image.__version__)
# 获取 OpenCV 版本号
print("OpenCV version:", cv2.__version__)
