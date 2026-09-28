
# :computer: Icon-Symbols

</br>

![Compiler](https://github.com/user-attachments/assets/a916143d-3f1b-4e1f-b1e0-1067ef9e0401) ![10 Seattle](https://github.com/user-attachments/assets/c70b7f21-688a-4239-87c9-9a03a8ff25ab) ![10 1 Berlin](https://github.com/user-attachments/assets/bdcd48fc-9f09-4830-b82e-d38c20492362) ![10 2 Tokyo](https://github.com/user-attachments/assets/5bdb9f86-7f44-4f7e-aed2-dd08de170bd5) ![10 3 Rio](https://github.com/user-attachments/assets/e7d09817-54b6-4d71-a373-22ee179cd49c)  ![10 4 Sydney](https://github.com/user-attachments/assets/e75342ca-1e24-4a7e-8fe3-ce22f307d881) ![11 Alexandria](https://github.com/user-attachments/assets/64f150d0-286a-4edd-acab-9f77f92d68ad) ![12 Athens](https://github.com/user-attachments/assets/59700807-6abf-4e6d-9439-5dc70fc0ceca)  
![Components](https://github.com/user-attachments/assets/d6a7a7a4-f10e-4df1-9c4f-b4a1a8db7f0e) <img src="https://github.com/user-attachments/assets/41db088c-4a71-4be9-bd1a-04bd3f29edef" />  
![Description](https://github.com/user-attachments/assets/dbf330e0-633c-4b31-a0ef-b1edb9ed5aa7) <img src="https://github.com/user-attachments/assets/cbe087dc-bad7-4eab-bb71-8993e29dcbda" />  
![Last Update](https://github.com/user-attachments/assets/e1d05f21-2a01-4ecf-94f3-b7bdff4d44dd) <img src="https://github.com/user-attachments/assets/814ab2dd-9dd0-45a5-b9c3-364f162fe819" />  
![License](https://github.com/user-attachments/assets/ff71a38b-8813-4a79-8774-09a2f3893b48) ![Freeware](https://github.com/user-attachments/assets/1fea2bbf-b296-4152-badd-e1cdae115c43)  

</br>

<img src="https://github.com/user-attachments/assets/f4ce9643-a6e0-4492-ad0a-69e6ce53012b" />

<br>
<br>

Icons as parts of the [graphical user interface](https://en.wikipedia.org/wiki/Graphical_user_interface) of a computer system, in conjunction with windows, menus and a [pointing device](https://en.wikipedia.org/wiki/Pointing_device) (mouse), belong to the much larger topic of the [history of the graphical user interface](https://en.wikipedia.org/wiki/History_of_the_graphical_user_interface) that has largely supplanted the text-based interface for casual use.

<br>

<img src="https://github.com/user-attachments/assets/19ac01bb-ca74-456d-b2cc-f8a2e1c6b2e6" />

<br>
<br>

Icons introduced in [Windows 1.0](https://en.wikipedia.org/wiki/Windows_1.0) were monochrome; in Windows 1.x and 2.x, ICO and CUR files were raw binary images with no directory wrapper: 678  — each file contained a single such image, at 64×64 pixels for icons and 32×32 for cursors.: 134  The 64×64 icon size was designed for a 1024×1024 target display and was shown downscaled on the lower-resolution monitors of the era.

<br>

# :speech_balloon: Structure
An ICO or CUR file is made up of an ICONDIR ("Icon directory") structure, containing an ICONDIRENTRY structure for each image in the file, followed by a contiguous block of all image data. Each image is stored either as a raw [DIB](https://en.wikipedia.org/wiki/BMP_file_format) (see [DIB format](https://en.wikipedia.org/wiki/ICO_(file_format)#DIB_format)) or as a complete [PNG](https://en.wikipedia.org/wiki/PNG) file (see [PNG format](https://en.wikipedia.org/wiki/ICO_(file_format)#PNG_format)). It is customary practice to store the image data in the same order as the entries in the image directory.

All values in ICO/CUR files are represented in little-endian byte order.

<br>

| Offset (bytes)	 | Field | Size (bytes) | Description |
| :------------ | :------------ | :------------ | :------------ |
| 0     | bWidth     | 1     | Image width in pixels. Can be any number between 0 and 255. 0 means width is 256.     |
| 1     | bHeight     | 1     | Image height in pixels. Can be any number between 0 and 255. 0 means height is 256.     |
| 2     | bColorCount     | 1     | Number of colors in the color table. For paletted depths: 2 for 1 bpp, 16 for 4 bpp; 0 for 8 bpp and above. An incorrect value affects [image selection scoring](https://en.wikipedia.org/wiki/ICO_(file_format)#Image_selection) for icons.     |
| 3     | bReserved     | 1     | Reserved. Must be 0.     |
| 4     | wPlanes     | 2     | In icon format: Specifies color planes. Should be 0 or 1. In cursor format: Specifies the horizontal coordinates of the hotspot in number of pixels from the left.     |
| 6     | wBitCount     | 2     | In icon format: Specifies bits per pixel. In cursor format: Specifies the vertical coordinates of the hotspot in number of pixels from the top.     |
| 8     | dwBytesInRes     | 4     | Image data size in bytes.     |
| 12     | dwImageOffset     | 4     | Specifies the [offset](https://en.wikipedia.org/wiki/Offset_(computer_science)) of the DIB or PNG data from the beginning of the ICO/CUR file.     |

<br>

# :speech_balloon: Examples
Icons (here are four examples from the [Nuvola icon theme](https://de.wikipedia.org/wiki/Nuvola)) are usually square and come in certain standard sizes.

Nuvola is a free software icon set under the GNU LGPL 2.1 license, created by David Vignoni. Originally created for [desktop environments](https://en.wikipedia.org/wiki/Desktop_environment) like KDE and GNOME, it is also available in packages for Windows and Mac. The final version, 1.0, contains almost 600 icons. The default set is in the PNG graphics format; an SVG version is also available.

The application icons, in particular, colourfully represent a wide variety of commonplace and easily recognised objects.

<br>

<img src="https://github.com/user-attachments/assets/d9887c6d-1b62-4c69-a5bd-0d69a07fbe6f" />

<br>

### Windows Notepad Editor

<br>

<img src="https://github.com/user-attachments/assets/6ed37e11-9c15-40fb-9f9e-803f5ccbb30d" />

<br>

# :speech_balloon: Icon size and color-depth timeline
The standard color depths and pixel sizes shipped in system icons changed over successive releases, as summarized below.

<br>

| Release | Color depths (bpp) | Standard sizes (px) | Notes |
| :----------- | :----------- | :----------- | :----------- |
| Windows 1.x–2.x     | 2     | 64 (icons), 32 (cursors)     | Raw single image, no directory     |
| Windows 3.x / NT 3.x     | 1,4     | 32     | ICONDIR + DIB introduced; 1 bpp + 4 bpp paired     |
| Windows 95     | 4     | 16, 32     | Higher depths supported by the shell but rarely shipped; 16 px is the small (taskbar/notification-area) icon size     |
| Windows NT 4.0 / 98 / Me / 2000     | 4,8     | 16, 32, 48     | 8 bpp and 48 px introduced in NT 4.0; became common by 98/Me     |
| Windows XP     | 4, 8, 32     | 16, 32, 48     | 32 bpp with alpha channel introduced     |
| Windows Vista / 7     | 4, 8, 32     | 16, 32, 48, 256     | 256 px added, stored as PNG     |
| Windows 8 / 8.1     | 4, 8, 32     | 16, 20, 24, 32, 40, 48, 64, 256     | Eight-size ladder completed     |
| Windows 10 / 11     | 32     | 16, 20, 24, 32, 40, 48, 64, 256     | Shipped icons are 32 bpp only     |


