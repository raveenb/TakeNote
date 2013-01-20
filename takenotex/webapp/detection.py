import sys
import cv2
import random
from math import pi
from math import sqrt

imagefiles = []

# for arg in sys.argv:
#     if arg != "detection.py":
#         imagefiles.append(arg)

# for imagefile in imagefiles:
def handle_opencv(imagefile):
    # Read in image
    img = cv2.imread(imagefile)
    # Convert to gray
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # Find height and width
    h,w = img.shape[:2]
    # Apply Gaussian Blur
    blur = cv2.GaussianBlur(gray, (9,9), 1)
    # Apply Canny edge detection
    edges = cv2.Canny(blur, 0.4*255, 0.4*0.4*255, imgcopy, 3)
    # Apply Hough line detection
    lines = cv2.HoughLinesP(edges, 1, pi/720, 150, None, min(h,w)/8, min(h,w)/50);

    # For later use in shape detection
    thirdleft = w/3
    thirdright = w*2/3
    thirdup = h/3
    thirddown = h*2/3
    n = 10
    xvalues = random.sample(range(thirdleft,thirdright),n)
    yvalues = random.sample(range(thirdup,thirddown),n)

    for line in lines[0]:
        # Find points
        pt1 = (line[0],line[1])
        pt2 = (line[2],line[3])
        if line[2] == line[0]:
            pt1x = (line[0],0)
            pt2x = (line[0],h)
            m = float("Inf")
        else:
            # Find slope m
            m = float(line[3] - line[1]) / float(line[2] - line[0])
            # Solve for b, far left
            b = int(line[1] - m*line[0])
            # Solve for y, far right
            y = int(m*w + b)
            # Find points
            pt1x = (0,b)
            pt2x = (w,y)

        # Draw lines
        # cv2.line(img, pt1x, pt2x, (0,0,127), 3)  #extended
        cv2.line(img, pt1, pt2, (0,0,255), 3)   #actual

        # SHAPE DETECTION


    # Write image (with lines) and edges to jpg
    outfile = imagefile[:-4] + "_out.jpg"
    #outfileedge = imagefile[:-4] + "edges.jpg"
    cv2.imwrite(outfile, img)
    #cv2.imwrite(outfileedge, edges)