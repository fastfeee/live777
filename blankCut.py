import cv2
import subprocess
import sys
# 检查是否提供了文件路径参数
if len(sys.argv) < 3:
    print("Usage: python script.py <input_file> <output_file>")
    sys.exit(1)

# 从命令行参数中获取输入文件路径
input_file = sys.argv[1]
output_file = sys.argv[2]
# 打开视频文件
video_capture = cv2.VideoCapture(input_file)

# 检查视频文件是否成功打开
if not video_capture.isOpened():
    print("Error: Unable to open input file")
    sys.exit(1)

# 视频的帧率
fps = video_capture.get(cv2.CAP_PROP_FPS)

# 视频的总帧数
total_frames = int(video_capture.get(cv2.CAP_PROP_FRAME_COUNT))

# 阈值设定
white_threshold = 240  # 像素值的平均值阈值

# 白色帧列表
white_frames = []

# 循环遍历视频的每一帧
for frame_num in range(total_frames):
    # 读取当前帧
    ret, frame = video_capture.read()

    # 如果无法读取帧，结束循环
    if not ret:
        break

    # 计算当前帧的像素值平均值
    avg_pixel_value = cv2.mean(frame)[0]

    # 如果像素值平均值高于阈值，则认为该帧是白色帧
    if avg_pixel_value > white_threshold:
        white_frames.append(frame_num )

# 打印白色帧的时间戳
print("白色帧的序号：", white_frames)

# 如果存在白色帧
if white_frames:
    # 获取最后一个白色帧的时间戳
    last_white_frame_index = white_frames[-1]
    print(last_white_frame_index)
    # 计算最后一个白色帧后面连续100帧的索引范围
    start_index = last_white_frame_index + 1
    end_index = min(last_white_frame_index + 101, total_frames)  # 确保不超过视频总帧数
    frame_rate = 25
    # 计算起始时间和持续时间（以秒为单位）
    start_time = start_index / frame_rate
    end_time = end_index / frame_rate
    print(start_time,end_time )
    # 使用ffmpeg截取视频
    cmd = [
        'ffmpeg',
        '-i', input_file,  # 输入文件
        '-ss', str(start_time),  # 开始时间
        '-to', str(end_time),# 结束时间
        '-c:v', 'libvpx',  #
        output_file  # 输出文件
    ]
    print(cmd)
    subprocess.run(cmd)

# 释放视频流
video_capture.release()
