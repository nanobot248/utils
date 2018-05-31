#!/bin/bash

# MIT License

# Copyright (c) 2018 Andreas Hubert

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


base_dir=~/Documents/screenshot-ocr
today=$(date --rfc-3339=date)
now=$(date +%H-%M-%S_%N)

outfile_name="${now}_screenshot.png"
outfile_path="${base_dir}/${today}/${outfile_name}"

outtext_name="${now}_screenshot"
outtext_path="${base_dir}/${today}/${outtext_name}"

# configure this to use another OCR utility. it should at least create an
# "${outtext_path}.pdf" file.
ocr_bin="$(which tesseract)"
ocr_flags="-l eng+deu+deu_frak ${outfile_path} ${outtext_path} pdf txt"
ocr_cmd="${ocr_bin} ${ocr_flags}"

# configure this to use another screenshot utility
screenshot_bin="$(which gnome-screenshot)"
screenshot_flags="-a --file=${outfile_path}"
screenshot_cmd="${screenshot_bin} ${screenshot_flags}"

# configure this to use a different viewer or to view different file formats.
# Note for PDFs: don't use evince. copy/paste handling for evince is totally
#      f*cked up. if you select/copy any multiline/-column text and paste it
#      somewhere, the pasted text will be scrambled (at least on Ubuntu 16.04).
viewer_bin="$(which chromium-browser)"
viewer_flags="file:///${outtext_path}.pdf"
viewer_cmd="${viewer_bin} ${viewer_flags}"

mkdir -p "${base_dir}/${today}"

if ! [ -d "${base_dir}/${today}" ]
then
	notify-send -i error "screenshot-ocr" "Could not create output directory!"
	exit 1
fi

echo "${screenshot_cmd}"
${screenshot_cmd}

if ! [ -f "$outfile_path" ]
then
	notify-send "screenshot-ocr" "No screenshot image was created."
	exit 2
fi

echo "${ocr_cmd}"
${ocr_cmd}

if ! [ -f "${outtext_path}.pdf" ]
then
	notify-send "screenshot-ocr" "Could not apply OCR on screenshot, no textfile was created."
	exit 3
fi

echo "${viewer_cmd}"
${viewer_cmd}


