#! /usr/bin/env python3
from shutil import copyfile
from PIL import Image
import PIL
import sys
import os

texPath = os.path.abspath("textures")

def generatePreview(skinPath):
    img = Image.open(skinPath)
    scaleX = round(img.size[0] / 64)
    scaleY = round(img.size[1] / 32)

    headFrontBox = (8 * scaleX, 8 * scaleX, 16 * scaleY, 16 * scaleY)
    chestFrontBox = (20 * scaleX, 20 * scaleX, 28 * scaleY, 32 * scaleY)
    armFrontBox = (44 * scaleX, 20 * scaleX, 48 * scaleY, 32 * scaleY)
    legsFront = (4 * scaleX, 20 * scaleX, 12 * scaleY, 32 * scaleY)

    preview = Image.new("RGBA", [16 * scaleX, 32 * scaleY])

    headFront = img.crop(headFrontBox)
    chestFront = img.crop(chestFrontBox)
    armFrontLeft = img.crop(armFrontBox)
    armFrontRight = armFrontLeft.transpose(PIL.Image.FLIP_LEFT_RIGHT)
    legsFront = img.crop(legsFront)

    preview.paste(headFront, (4 * scaleX, 0 * scaleY))
    preview.paste(chestFront, (4 * scaleX, 8 * scaleY))
    preview.paste(armFrontLeft, (0 * scaleX, 8 * scaleY))
    preview.paste(armFrontRight, (12 * scaleX, 8 * scaleY))
    preview.paste(legsFront, (4 * scaleX, 20 * scaleY))
    return preview

def help():
    print("This script is used to add textures and generate preview images for textures.")
    print("Commands:")
    print("add <texture path>     Adds texture at <path>")
    print("makepreviews    Generates previews for all textures currently added")
    print("help    Displays this help message")

args = sys.argv[1:]
if len(args) == 0:
    help()
    sys.exit()

cmd = args[0]
if cmd == "add":
    if len(args) < 2:
        help()
        sys.exit()
    else:
        # Get and copy skin
        pathes = args[1:]
        for path in pathes:
            # Get current name of skin
            name = os.path.basename(path)
            # Get new name of skin
            numSkins = 0
            for s in os.listdir(texPath):
                if s.startswith("texture_") and s.endswith(".png"):
                    numSkins += 1
            newname = "texture_{0}.png".format(numSkins + 1)
            newpath = os.path.join(texPath, newname)
            print("Adding {0} as {1} ...".format(name, newname))
            # Copy skin over
            copyfile(path, newpath)
            # Check skin size
            skin = Image.open(newpath)
            ratio = skin.size[0] / skin.size[1]
            if ratio == 1: # MineCraft skin
                print ("Found MineCraft skin ({0}x{1})".format(*skin.size))
                box = (0, 0, skin.size[0], skin.size[0] / 2)
                skin = skin.crop(box)
                skin.save(newpath)
                print ("Cropped to {0}x{1}".format(box[2], box[3]))
            elif ratio != 2:
                print("Warning: Found skin with strange dimensions ({0}x{1})".format(*skin.size))
            print("Done")
elif cmd == "makepreviews":
    for t in os.listdir(texPath):
        if t.startswith("texture_"):
            name = t[8:]
            absPath = os.path.join(texPath, t)
            preview = generatePreview(absPath)
            previewPath = os.path.join(texPath, "preview_" + name)
            preview.save(previewPath)
            print("Generated preview for " + t)
else:
    help()
