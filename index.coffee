# This file is part of image-helpers
# Copyright (C) 2018-present Dario Giovannetti <dev@dariogiovannetti.net>
# Licensed under MIT
# https://github.com/kynikos/lib.js.image-helpers/blob/master/LICENSE

path = require('path')

blueimpLoadImage = require('blueimp-load-image')

# https://github.com/blueimp/JavaScript-Canvas-to-Blob
# This is also a polyfill for <canvas>.toBlob()
module.exports.dataURLtoBlob = require('blueimp-canvas-to-blob')


# https://github.com/blueimp/JavaScript-Load-Image
module.exports.loadImage = loadImage = (inputFile, options) ->
    new Promise((resolve, reject) ->
        blueimpLoadImage(
            inputFile
            (img) ->
                if img.type is 'error'
                    return reject(img)

                return resolve(img)

            options
        )
    )


# https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/toBlob
module.exports.canvasToBlob = canvasToBlob = (
    canvas, mimeType, qualityArgument,
) ->
    new Promise((resolve, reject) ->
        canvas.toBlob(
            (blob) ->
                return resolve(blob)

            mimeType,
            qualityArgument,
        )
    )


module.exports.inputImagesToFormData = ({
    inputFile
    formData
    formName
    forceExtension
    # Don't give a default value to makeFileName here
    makeFileName
    optsLoadImage
    mimeType
    qualityArgument
}) ->
    # canvasToBlob requires a canvas
    optsLoadImage.canvas = true

    promises = for file in inputFile.files
        if makeFileName
            fileName = makeFileName(file)
        else if forceExtension
            baseName = path.basename(file.name, path.extname(file.name))
            fileName = baseName + '.' + forceExtension
        else
            fileName = file.filename

        do (fileName) ->
            loadImage(file, optsLoadImage).then((canvas) ->
                canvasToBlob(canvas, mimeType, qualityArgument)
            ).then((blob) ->
                formData.append(formName, blob, fileName)
                return blob
            )

    return Promise.all(promises)
