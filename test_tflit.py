#! /usr/bin/env python3
# adapted from label_image.py demo, using tflit wrapper for ease of use =)

import sys, os, math, tflit
from PIL import Image
import numpy as np

# Process an image file
def process(model, image):
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
            eb = math.exp(res[y][x][0])
            ep = math.exp(res[y][x][1])
            pb = eb/(ep+eb)
            pp = ep/(ep+eb)
            # drop pixel into image according to type
            if pp>pb:
                img.putpixel((x,y),0x0000ff)
                hasper = True
    return (img, hasper)

if __name__ == '__main__':
    tfmodel = os.getenv('HOME')+'/projects/deepbacksub/models/segm_lite_v509_128x128_opt_float32.tflite'
    images = []
    verbose = False
    arg = 1
    while arg<len(sys.argv):
        if sys.argv[arg].startswith('-m'):
            tfmodel = sys.argv[arg+1]
            arg+=1
        elif sys.argv[arg].startswith('-v'):
            verbose = True
        elif sys.argv[arg].startswith('-h'):
            print(f'usage: {sys.argv[0]}: [-m <tflite model:{tfmodel}>] [-v(erbose)] <image> ...')
            sys.exit(0)
        else:
            images.append(sys.argv[arg])
        arg+=1
    # load the model
    print('model:',tfmodel)
    model = tflit.Model(tfmodel)
    # process the images
    for image in images:
        try:
            (img, hasper) = process(model, image)
            if verbose:
                img.show()
            print(hasper, image)
        except:
            print('Exception',image)
