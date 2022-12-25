import cv2 as cv
import multiprocessing as mp
import numpy as np

path = "bbad.mp4"
resized_size = (475, 167)

color_map = [[[0 for k in range(256)] for j in range(256)] for i in range(256)]
COLORS = {
    "black": ["0", (0, 0, 0)],
    "silver": ["7", (192, 192, 192)],
    "gray": ["8", (128, 128, 128)],
    "white": ["F", (255, 255, 255)],
    "maroon": ["4", (128, 0, 0)],
    "red": ["C", (255, 0, 0)],
    "purple": ["5", (128, 0, 128)],
    "fuchsia": ["D", (255, 0, 255)],
    "green": ["2", (0, 128, 0)],
    "lime": ["A", (0, 255, 0)],
    "olive": ["6", (128, 128, 0)],
    "yellow": ["E", (255, 255, 0)],
    "navy": ["1", (0, 0, 128)],
    "blue": ["9", (0, 0, 255)],
    "teal": ["3", (0, 128, 128)],
    "aqua": ["B", (0, 255, 255)]
}


def gen_chart():
    global color_map
    tasks = [(i, j, k) for k in range(256) for j in range(256) for i in range(256)]
    with mp.Pool() as p:
        res = p.map(cal_color, tasks)
        for res in res:
            location = res[1]
            color_code = res[0]
            color_map[location[2]][location[1]][location[0]] = color_code
    print("Generation done.")


def cal_color(task_config: tuple):
    i, j, k = task_config
    min_dist = None
    for color, config in COLORS.items():
        color_code = config[1]
        dist = (color_code[0] - i) ** 2 + (color_code[1] - j) ** 2 + (color_code[2] - k) ** 2
        if min_dist is None:
            min_dist = (color, dist)
        else:
            if min_dist[1] > dist:
                min_dist = (color, dist)
    return COLORS[min_dist[0]][0], (i, j, k)


def process_string(array: np.ndarray) -> str:
    temp = []
    (n, m) = array.shape
    for i in range(n):
        color = color_map[array[i][0]][array[i][1]][array[i][2]]
        temp.append(str(color))
    return "".join(temp)


def main():
    global path, color_map, resized_size
    cap = cv.VideoCapture(path)
    spf = 1 / 30
    cur_sec = 0
    buffer = ""
    frame_count = 0

    while cap.isOpened():
        ret, frame = cap.read()
        cur_sec += spf

        if ret is True:
            frame = cv.resize(frame, resized_size, interpolation=cv.INTER_LINEAR)
            np.asarray(frame, order="C")
            frame = np.reshape(frame, (-1, 3))
            frame_txt = process_string(frame)
            buffer = "".join((buffer, "{0:0>6.0f}{1:}\n".format(cur_sec * 1000, frame_txt)))
            frame_count += 1
            print("{}th frame done.".format(frame_count))
        else:
            buffer = "{0:0>6.0f}\n".format((cur_sec - spf) * 1000) + buffer
            buffer += "SSSSSS"
            print("All frame done.")
            break

    with open("encoded.txt", "w") as output:
        output.write(buffer)
        print("File outputted.")
    cap.release()


if __name__ == "__main__":
    gen_chart()
    main()