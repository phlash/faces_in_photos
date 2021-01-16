#! /usr/bin/env python3
# adapted from label_image.py demo, using tflit wrapper for ease of use =)

import sys, os, math, tflit
from PIL import Image
import numpy as np

labels = [ "background", "aeroplane", "bicycle", "bird", "boat", "bottle", "bus", "car", "cat", "chair", "cow", "dining table", "dog", "horse", "motorbike", "person", "potted plant", "sheep", "sofa", "train", "tv" ]
ipers = labels.index("person")

# Process an image file
def process(model, isDeepseg, image):
    # load image from disk.. ensure RGB format
    img = Image.open(image).convert('RGB')
    # resize to model
    h = model.input_details[0]['shape'][1]
    w = model.input_details[0]['shape'][2]
    img = img.resize((w, h))
    # wrap in an outer array for TF
    datain = np.expand_dims(img, axis=0)
    # map 0-255 rgb into -1>1 floats
    datain = (np.float32(datain) - 127.5)/127.5
    # set as input to tf
    model.interpreter.set_tensor(model.input_details[0]['index'], datain)
    # run the model
    model.interpreter.invoke()
    # grab output
    dataout = model.interpreter.get_tensor(model.output_details[0]['index'])
    # reduce from nested array (inverse of above)
    res = np.squeeze(dataout)
    # walk output pixels, find most likely type (background/person)
    hasper = False
    for y in range(0,len(res)):
        for x in range(0,len(res[y])):
            isPer = False
            # Deepseg? or Segm / Google meet?
            if isDeepseg:
                maxv = res[y][x][0]
                mpos = 0
                for i in range(1,len(res[y][x])):
                    if res[y][x][i]>maxv:
                        maxv = res[y][x][i]
                        mpos = i
                isPer = (mpos==ipers)
            else:
                eb = math.exp(res[y][x][0])
                ep = math.exp(res[y][x][1])
                pb = eb/(ep+eb)
                pp = ep/(ep+eb)
                isPer = pp>pb
            # drop pixel into image according to type
            if isPer:
                img.putpixel((x,y),0x0000ff)
                hasper = True
    return (img, hasper)

if __name__ == '__main__':
    segm = os.getenv('HOME')+'/projects/deepbacksub/models/segm_lite_v509_128x128_opt_float32.tflite'
    deep = os.getenv('HOME')+'/projects/deepbacksub/models/deeplabv3_257_mv_gpu.tflite'
    isDeep = False
    images = []
    verbose = False
    arg = 1
    while arg<len(sys.argv):
        if sys.argv[arg].startswith('-d'):
            isDeep = True
        elif sys.argv[arg].startswith('-v'):
            verbose = True
        elif sys.argv[arg].startswith('-h'):
            print(f'usage: {sys.argv[0]}: [-d (use deepseg)] [-v(erbose)] <image> ...')
            sys.exit(0)
        else:
            images.append(sys.argv[arg])
        arg+=1
    # load the model
    tfmod = deep if isDeep else segm
    print('model:',tfmod)
    model = tflit.Model(tfmod)
    # process the images
    for image in images:
        try:
            (img, hasper) = process(model, isDeep, image)
            if verbose:
                img.show()
            print(hasper, image)
        except:
            print('Exception',image)
