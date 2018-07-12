# USAGE
# python pi_surveillance.py --conf conf.json

# import the necessary packages
from pyimagesearch.tempimage import TempImage
from picamera.array import PiRGBArray
from picamera import PiCamera
import argparse
import warnings
import datetime
# import dropbox
import imutils
import json
import time
import cv2
import numpy as np

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-c", "--conf", required=True,
	help="path to the JSON configuration file")
args = vars(ap.parse_args())

# define the list of colour boundaries (BGR)
boundaries = [
	([0, 70, 0], [180, 255, 180]),
	# ([86, 31, 4], [220, 88, 50]),
	# ([25, 146, 190], [62, 174, 250]),
	# ([103, 86, 65], [145, 133, 128])
]
greenlower = [0, 70, 0]
greenupper = [180, 255, 180]


# boundaries = [
# 	([29, 86, 6], [64, 255, 255]),
# 	# ([86, 31, 4], [220, 88, 50]),
# 	# ([25, 146, 190], [62, 174, 250]),
# 	# ([103, 86, 65], [145, 133, 128])
# ]


# filter warnings, load the configuration and initialize the Dropbox
# client
warnings.filterwarnings("ignore")
conf = json.load(open(args["conf"]))
client = None

# initialize the camera and grab a reference to the raw camera capture
camera = PiCamera()
camera.resolution = tuple(conf["resolution"])
camera.framerate = conf["fps"]
rawCapture = PiRGBArray(camera, size=tuple(conf["resolution"]))

# allow the camera to warmup, then initialize the average frame, last
# uploaded timestamp, and frame motion counter
print("[INFO] warming up...")
time.sleep(conf["camera_warmup_time"])
avg = None
lastUploaded = datetime.datetime.now()
motionCounter = 0

# capture frames from the camera
for f in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
	# grab the raw NumPy array representing the image and initialize
	# the timestamp and occupied/unoccupied text
	frame = f.array
	timestamp = datetime.datetime.now()
	text = "No Target"

	# resize the frame
	frame = imutils.resize(frame, width=500)

	# create NumPy arrays from the boundaries
	lower = np.array(greenlower, dtype = "uint8")
	upper = np.array(greenupper, dtype = "uint8")

	# find the colors within the specified boundaries and apply
	# the mask
	mask = cv2.inRange(frame, lower, upper)
	filtered_frame = cv2.bitwise_and(frame, frame, mask = mask)
	
	# convert frae to gray scale and blur it
	gray_original = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
	gray_original = cv2.GaussianBlur(gray_original, (21, 21), 0)
	gray_filtered = cv2.cvtColor(filtered_frame, cv2.COLOR_BGR2GRAY)
	gray_filtered = cv2.GaussianBlur(gray_filtered, (21, 21), 0)

	# compute the difference between the current frame and the moddified one
	frameDelta = cv2.absdiff(gray_filtered, gray_original)

	# threshold the delta image, dilate the thresholded image to fill
	# in holes, then find contours on thresholded image
	thresh = cv2.threshold(frameDelta, conf["delta_thresh"], 255,
		cv2.THRESH_BINARY)[1]
	thresh = cv2.dilate(thresh, None, iterations=2)
	cnts = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL,
		cv2.CHAIN_APPROX_SIMPLE)
	cnts = cnts[0] if imutils.is_cv2() else cnts[1]

	# loop over the contours
	for c in cnts:
		# if the contour is too small, ignore it
		if cv2.contourArea(c) < conf["min_area"]:
			continue

		# compute the bounding box for the contour, draw it on the frame,
		# and update the text
		(x, y, w, h) = cv2.boundingRect(c)
		cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
		text = "Target Detected"	

	# draw the text and timestamp on the frame
	ts = timestamp.strftime("%A %d %B %Y %I:%M:%S%p")
	cv2.putText(frame, "Status: {}".format(text), (10, 20),
		cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)
	cv2.putText(frame, ts, (10, frame.shape[0] - 10), cv2.FONT_HERSHEY_SIMPLEX,
		0.35, (0, 0, 255), 1)


	# check to see if the frames should be displayed to screen
	if conf["show_video"]:
		# display the Live stream scan
		# cv2.imshow("Live stream scan", frame)
		cv2.imshow("Live stream scan", np.hstack([frame, filtered_frame]))
		key = cv2.waitKey(1) & 0xFF

		# if the `q` key is pressed, break from the loop
		if key == ord("q"):
			break

	# clear the stream in preparation for the next frame
	rawCapture.truncate(0)
