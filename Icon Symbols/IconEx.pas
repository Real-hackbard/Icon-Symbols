unit IconEx;

interface

  {$DEFINE USE_ASM}
  {$A+,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}

uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics;

type
  PIconDirectoryEntry = ^TIconDirectoryEntry;
  TIconDirectoryEntry = packed record
    bWidth: Byte;
    bHeight: Byte;
    wColorCount: Word;
    wPlanes: Word;
    wBitCount: Word;
    dwBytesInRes: DWORD;
    dwImageOffset: DWORD;
  end;

  TIconExFormatSet = set of Byte;

  TCustomIconEx = class(TGraphicControl)
  private
    FIconDir: TCursorOrIcon;
    FIconDirectoryEntry: array of TIconDirectoryEntry;
    FAlphaBitmap: TBitmap;
    ColorTable: array of Byte;
    FCurrentBitmapInfo: PBitmapInfoHeader;
    FPropertyIcon: TIcon;
    FCurrentFormat: Integer;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseEnter : TNotifyEvent;
    procedure SetCurrentFormat(const Value: Integer);
    function GetFormatCount: Integer;
    function GetIconFormat(Index: Integer): TIconDirectoryEntry;
    procedure SetIcon(const Value: TIcon);
  protected
    procedure EmptyIconInfo; virtual;
    function GetBitmapInfo(const Format: Integer): PBitmapInfoHeader;
    procedure GetDIBBitmapEx(var BI: TBitmapInfoHeader; const ACanvas: TCanvas;
      P: TPoint); virtual;
    procedure OnIconChange(Sender: TObject); virtual;
    procedure UpdateIconInfo; virtual;
    procedure Paint; override;
    procedure CMMouseEnter(var AMsg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var AMsg: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure ShowBestFormat; virtual;
    procedure SaveToFile(const FileName: String; Formats: TIconExFormatSet);
    procedure SaveToStream(Stream: TStream; Formats: TIconExFormatSet);
    property FormatCount: Integer read GetFormatCount;
    property IconFormats[Index: Integer]: TIconDirectoryEntry read
      GetIconFormat;
  published
    property Icon: TIcon read FPropertyIcon write SetIcon;
    property CurrentFormat: Integer read FCurrentFormat write SetCurrentFormat default -1;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
  end;

  TIconEx = class(TCustomIconEx)
  published
    property Align;
    property Anchors;
    property AutoSize;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseLeave;
    property OnMouseEnter;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

uses
  Unit1, Consts, RTLConsts;

procedure OutOfResources;
begin
  //raise //EOutOfResources.Create(SOutOfResources);
  Form1.IconEx1.Canvas.Font.Color := clBlack;
  Form1.IconEx1.Canvas.Textout(10,10, 'Windows icons, 256x256 format');
  Form1.IconEx1.Canvas.Textout(10,26, 'Internal PNG compression error!');
  Form1.IconEx1.Canvas.Textout(10,42, 'Remove the (256x256) set,');
  Form1.IconEx1.Canvas.Textout(10,58, 'or convert the symbols');
  Form1.IconEx1.Canvas.Textout(10,74, 'in a bitmap format.');
  Form1.IconEx1.Canvas.Font.Color := clNavy;
  Form1.IconEx1.Canvas.Textout(10,106, 'The format cannot be displayed,');
  Form1.IconEx1.Canvas.Textout(10,118, 'but it remains in the icon container.');
  Form1.IconEx1.Canvas.Font.Color := clBlack;
  Form1.IconEx1.Canvas.Textout(10,150, 'To display this format,');
  Form1.IconEx1.Canvas.Textout(10,166, 'you need the "PNG library",');
  Form1.IconEx1.Canvas.Textout(10,182, 'to decompress the PNG graphic.');
end;

procedure GDIError;
var
  ErrorCode: Integer;
  Buf: array [Byte] of Char;
begin
  ErrorCode := GetLastError;
  if (ErrorCode <> 0) and (FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil,
    ErrorCode, LOCALE_USER_DEFAULT, Buf, sizeof(Buf), nil) <> 0) then
    //raise EOutOfResources.Create(Buf)
  else
    OutOfResources;
end;

{$IFNDEF USE_ASM}

procedure MakeAlphaBlend(DIBColorSrc, DIBDest: PRGBQuad;
  const DIBColorSrcSize: Integer);  
var
  I: Integer;
begin
  for I := 0 to (DIBColorSrcSize shr 2) - 1 do
  begin
    if DIBColorSrc^.rgbReserved = 255 then
      DIBDest^ := DIBColorSrc^
    else
      if DIBColorSrc^.rgbReserved > 0 then
      begin
        DIBDest^.rgbBlue := Byte(MulDiv(DIBColorSrc^.rgbBlue,
          DIBColorSrc^.rgbReserved, 255)
          + MulDiv(DIBDest^.rgbBlue, 255 - DIBColorSrc^.rgbReserved, 255));
        DIBDest^.rgbGreen := Byte(MulDiv(DIBColorSrc^.rgbGreen,
          DIBColorSrc^.rgbReserved, 255)
          + MulDiv(DIBDest^.rgbGreen, 255 - DIBColorSrc^.rgbReserved, 255));
        DIBDest^.rgbRed := Byte(MulDiv(DIBColorSrc^.rgbRed,
          DIBColorSrc^.rgbReserved, 255)
          + MulDiv(DIBDest^.rgbRed, 255 - DIBColorSrc^.rgbReserved, 255));
      end;
    Inc(DIBDest);
    Inc(DIBColorSrc);
  end;
end;

{$ELSE}

procedure MakeAlphaBlend(DIBColorSrc, DIBDest: PRGBQuad;
  const DIBColorSrcSize: Integer); assembler;
asm
  push eax
  push ebx
  push ecx
  push edx
  push edi
  push esi
  mov  esi, DIBColorSrc
  mov  edi, DIBDest
  //mov  ecx, DIBColorSrcSize
  shr  ecx, 2

@loop:

  mov  al, [esi + 3]
  cmp  al, 0
  jne  @paint_full

  add  esi, 4
  add  edi, 4
  loop @loop
  jmp  @done


@paint_full:
  cmp  al, 255
  jne  @paint_alpha

  mov  eax, [esi]
  mov  [edi], eax

  add  esi, 4
  add  edi, 4
  loop @loop
  jmp  @done

@paint_alpha:

  xor  ebx, ebx
  call @make_alpha
  inc  ebx
  call @make_alpha
  inc  ebx
  call @make_alpha

  add  esi, 4
  add  edi, 4
  loop @loop
  jmp  @done


@make_alpha:

  xor  eax, eax
  xor  edx, edx
  mov  al, byte [edi + ebx]
  mov  dl, byte [esi + 3]
  not  dl
  mul  dl
  or   dl, $FF
  div  dl

  mov  byte [edi + ebx], al

  xor  eax, eax
  xor  edx, edx
  mov  al, byte [esi + ebx]
  mov  dl, byte [esi + 3]
  mul  dl
  or   dl, $FF
  div  dl

  xor  edx, edx
  mov  dl, byte [edi + ebx]
  add  ax, dx
  mov  byte [edi + ebx], al

  ret

@done:
  pop  esi
  pop  edi
  pop  edx
  pop  ecx
  pop  ebx
  pop  eax
end;

{$ENDIF}

procedure TCustomIconEx.GetDIBBitmapEx(var BI: TBitmapInfoHeader;
  const ACanvas: TCanvas; P: TPoint);

  function GDICheck(Value: Integer): Integer;
  begin
    if Value = 0 then GDIError;
    Result := Value;
  end;

type
  PLongArray = ^TLongArray;
  TLongArray = array[0..1] of Longint;
var
  I, A, C, nNumColors: Integer;
  pColorTable, pDIBColor, pDIBMask: Pointer;
  nColorTableSize, nDIBColorSize{, nDIBMaskSize}: DWORD;
  hDIBColor, hDIBMask: HBITMAP;
  pColorBuffer, pMaskBuffer: Pointer;
  hdcColor, hdcMask, hdcTempColor, hdcTempMask, DC: HDC;
  Colors: PLongArray;
  DestBits: array[0..$FFFF] of TRGBQuad;
  //pDestBits: Pointer;
  pRGB{, RGBQuad}: PRGBQuad;
begin
  with BI do
  begin
    biHeight := biHeight shr 1;
    biSizeImage := BytesPerScanline(biWidth, biBitCount, 32) * biHeight;
    case biBitCount of
      1, 4, 8, 16: nNumColors := 1 shl biBitCount;
    else
      nNumColors := 0;
    end;
  end;
  try
    nColorTableSize := nNumColors * SizeOf(TRGBQuad);
    nDIBColorSize := (((BI.biWidth * BI.biBitCount + 31) shr 5) * BI.biHeight) shl 2;

    { calculates the size of the buffer in bytes required for a 1-bit-per-pixel
      mask (such as a monochrome bitmap or a transparency mask) of a GDI bitmap }
    //nDIBMaskSize := (((BI.biWidth + 31) shr 5)* BI.biHeight) shl 2;

    pColorTable := Pointer(DWORD(@BI) + SizeOf(BI));
    pDIBColor := Pointer(DWORD(pColorTable) + nColorTableSize);
    pDIBMask :=  Pointer(DWORD(pDIBColor) + nDIBColorSize);
    if BI.biBitCount = 32 then
    begin

      { Retrieving the memory address of the first element of an
        array (or dynamic array) and assigning it to a pointer. }
      //pDestBits := @DestBits[0];

      FAlphaBitmap.Width := BI.biWidth;
      FAlphaBitmap.Height := BI.biHeight;
      FAlphaBitmap.PixelFormat := pf32bit;

      BitBlt(FAlphaBitmap.Canvas.Handle, 0, 0, BI.biWidth, BI.biHeight,
        ACanvas.Handle, P.X, P.Y, SRCCOPY);

      C := 0;
      for I := BI.biHeight - 1 downto 0 do
      begin
        pRGB := FAlphaBitmap.ScanLine[I];
        //C := ((BI.biHeight - 1) - I) * BI.biHeight; // BUG FIX
        for A := 0 to BI.biWidth - 1 do
        begin
          { copies a color pixel structure from a dereferenced pointer (pRGB^)
            into a specific memory location or array index (DestBits[A+C]). }
          //DestBits[A+C] := pRGB^; // BUG FIX

          DestBits[C] := pRGB^;
          Inc(pRGB);
          Inc(C)
        end;
      end;
      MakeAlphaBlend(PRGBQuad(pDIBColor),
        PRGBQuad(@DestBits[0]), nDIBColorSize);

      C := 0;
      for I := BI.biHeight - 1 downto 0 do
      begin
        pRGB := FAlphaBitmap.ScanLine[I];

        { manual image processing of DIBs (Device-Independent Bitmaps) }
        //C := ((BI.biHeight - 1) - I) * BI.biHeight; // BUG FIX

        for A := 0 to BI.biWidth - 1 do
        begin
          { direct pixel manipulation in a bitmap (usually via the
            ScanLine property). The expression pRGB^ := DestBits[C + A]
            copies a color or pixel value from a source array (DestBits)
            to the memory address currently pointed to by the pointer pRGB. }
          //pRGB^ := DestBits[C + A]; // BUG FIX

          pRGB^ := DestBits[C];
          Inc(pRGB);
          Inc(c);
        end;
      end;

      BitBlt(ACanvas.Handle, P.X, P.Y, BI.biWidth, BI.biHeight,
        FAlphaBitmap.Canvas.Handle, 0, 0, SRCCOPY);

      Exit;
    end;

    DC := GetDC(0);
    if DC = 0 then OutOfResources;
    try
      pColorBuffer := nil;
      hDIBColor := GDICheck(CreateDIBSection(DC, PBitmapInfo(@BI)^,
        DIB_RGB_COLORS, pColorBuffer, 0, 0));
      try
        hdcColor := GDICheck(CreateCompatibleDC(DC));
        try
          hdcTempColor := SelectObject(hdcColor, hDIBColor);
          try
            SetBkColor(hdcColor, RGB(1, 1, 1));
            SetDIBitsToDevice(hdcColor, 0, 0, BI.biWidth, BI.biHeight, 0,
              0, 0, BI.biHeight, pDIBColor, PBitmapInfo(@BI)^, DIB_RGB_COLORS);

            with BI do
            begin
              biBitCount := 1;
              biSizeImage := BytesPerScanline(biWidth, biBitCount, 32) * biHeight;
              biClrUsed := 2;
              biClrImportant := 2;
            end;
            Colors := Pointer(DWORD(@BI) + SizeOf(BI));
            Colors^[0] := 0;
            Colors^[1] := $FFFFFF;

            pMaskBuffer := nil;
            hDIBMask := GDICheck(CreateDIBSection(0, PBitmapInfo(@BI)^,
              DIB_RGB_COLORS, pMaskBuffer, 0, 0));
            try
              hdcMask := GDICheck(CreateCompatibleDC(0));
              try
                hdcTempMask := SelectObject(hdcMask, hDIBMask);
                try
                  SetDIBitsToDevice (hdcMask, 0, 0, BI.biWidth, BI.biHeight, 0,
                    0, 0, BI.biHeight, pDIBMask, PBitmapInfo(@BI)^, DIB_RGB_COLORS);

                  BitBlt(ACanvas.Handle, P.X, P.Y, BI.biWidth, BI.biHeight,
                    hdcMask, 0, 0, SRCAND);
                finally
                  SelectObject(hdcMask, hdcTempMask);
                end;
              finally
                DeleteObject(hdcMask);
              end;
            finally
              DeleteObject(hDIBMask);
            end;
            BitBlt(ACanvas.Handle, P.X, P.Y, BI.biWidth, BI.biHeight,
              hdcColor, 0, 0, SRCINVERT);
          finally
            SelectObject(hdcColor, hdcTempColor);
          end;
        finally
          DeleteObject(hdcColor);
        end;
      finally
        DeleteObject(hDIBColor);
      end;
    finally
      ReleaseDC(0, DC);
    end;
  finally
    BI.biHeight := BI.biHeight shl 1;
  end;
end;

{ TCustomIconEx }
constructor TCustomIconEx.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle - [csOpaque];
  FPropertyIcon := TIcon.Create;
  FPropertyIcon.OnChange := OnIconChange;
  FAlphaBitmap := nil;
  Height := 105;
  Width := Height;
  EmptyIconInfo;
end;

destructor TCustomIconEx.Destroy;
begin
  EmptyIconInfo;
  FPropertyIcon.Free;
  inherited;
end;

procedure TCustomIconEx.EmptyIconInfo;
begin
  if FAlphaBitmap <> nil then
    FreeAndNil(FAlphaBitmap);
  FCurrentBitmapInfo := nil;
  ZeroMemory(@FIconDir, SizeOf(TCursorOrIcon));
  SetLength(FIconDirectoryEntry, 0);
  FCurrentFormat := -1;
end;

procedure TCustomIconEx.ShowBestFormat;
var
  BestWithPerHeight, BestColorDepth, TmpBestWithPerHeight: DWORD;
  I, BestFormat: Integer;
begin
  BestFormat := -1;
  BestWithPerHeight := 0;
  BestColorDepth := 0;
  if FormatCount = 0 then
  begin
    CurrentFormat := -1;
    Exit;
  end;
  for I := 0 to FormatCount - 1 do
  begin
    TmpBestWithPerHeight := FIconDirectoryEntry[I].bWidth *
      FIconDirectoryEntry[I].bHeight;
    if FIconDirectoryEntry[I].wBitCount > BestColorDepth then
    begin
      BestColorDepth := FIconDirectoryEntry[I].wBitCount;
      BestWithPerHeight := TmpBestWithPerHeight;
      BestFormat := I;
    end;

    if (TmpBestWithPerHeight > BestWithPerHeight) then
      if FIconDirectoryEntry[I].wBitCount = BestColorDepth then
      begin
        BestWithPerHeight := TmpBestWithPerHeight;
        BestFormat := I;
      end;
  end;
  CurrentFormat := BestFormat;
end;

function TCustomIconEx.GetBitmapInfo(const Format: Integer): PBitmapInfoHeader;
var
  Stream: TMemoryStream;
begin
  Result := nil;

  if Format = -1 then Exit;
  
  if (Format < 0) or (Format >= FormatCount) then
    raise EListError.CreateResFmt(@SListIndexError, [Format]);

  Stream := TMemoryStream.Create;
  try
    FPropertyIcon.SaveToStream(Stream);
    Stream.Position := FIconDirectoryEntry[Format].dwImageOffset;
    SetLength(ColorTable, FIconDirectoryEntry[Format].dwBytesInRes);
    Stream.Read(ColorTable[0], FIconDirectoryEntry[Format].dwBytesInRes);
    Result := PBitmapInfoHeader(@ColorTable[0]);
  finally
    Stream.Free;
  end;
end;

function TCustomIconEx.GetFormatCount: Integer;
begin
  Result := FIconDir.Count;
end;

function TCustomIconEx.GetIconFormat(Index: Integer): TIconDirectoryEntry;
begin
  if (Index < -1) or (Index >= FormatCount) then
    raise EListError.CreateResFmt(@SListIndexError, [Index]);
  Result := FIconDirectoryEntry[Index];
end;

procedure TCustomIconEx.UpdateIconInfo;
var
  Stream: TMemoryStream;
  I: Integer;
begin
  EmptyIconInfo;
  Stream := TMemoryStream.Create;
  try
    FPropertyIcon.SaveToStream(Stream);
    Stream.Position := 0;
    Stream.Read(FIconDir, SizeOf(TCursorOrIcon));
    SetLength(FIconDirectoryEntry, FIconDir.Count);
    for I := 0 to FIconDir.Count - 1 do
    begin
      Stream.Read(FIconDirectoryEntry[I], SizeOf(TIconDirectoryEntry));
      Dec(FIconDirectoryEntry[I].bWidth, Byte(FIconDirectoryEntry[I].bWidth = 0));
      Dec(FIconDirectoryEntry[I].bHeight, Byte(FIconDirectoryEntry[I].bHeight = 0));
      if FIconDirectoryEntry[I].wBitCount = 32 then
        if FAlphaBitmap = nil then FAlphaBitmap := TBitmap.Create;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TCustomIconEx.OnIconChange(Sender: TObject);
begin
  if FPropertyIcon.Empty then
  begin
    EmptyIconInfo;
    Invalidate;
  end
  else
  begin
    UpdateIconInfo;
    ShowBestFormat;
  end;
end;

procedure TCustomIconEx.Paint;
var
  ACurrentBitmapInfo: PBitmapInfoHeader;
begin
  inherited;
  Canvas.Lock;
  try
  
    if csDesigning in ComponentState then
    begin
      Canvas.Pen.Style := psDash;
      Canvas.Pen.Color := clBlack;
      Canvas.Brush.Style := bsClear;
      Canvas.Rectangle(GetClientRect);
    end;

    if FormatCount > 0 then
      if CurrentFormat >= 0 then
	    begin
        ACurrentBitmapInfo := GetBitmapInfo(FCurrentFormat); // BUG FIX
        GetDIBBitmapEx(ACurrentBitmapInfo^, Canvas, Point(0, 0));
      end;
  finally
    Canvas.Unlock;
  end;
end;

procedure TCustomIconEx.SaveToFile(const FileName: String;
  Formats: TIconExFormatSet);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(F, Formats);
    FlushFileBuffers(F.Handle);
  finally
    F.Free;
  end;
end;

procedure TCustomIconEx.SaveToStream(Stream: TStream;
  Formats: TIconExFormatSet);
var
  IconDir: TCursorOrIcon;
  IconDirectoryEntryes: array of TIconDirectoryEntry;
  NeedFormatCount, I: Integer;
  IcoStream: TMemoryStream;
begin
  Stream.Size := 0;

  NeedFormatCount := 0;
  SetLength(IconDirectoryEntryes, FormatCount);
  for I := 0 to FormatCount - 1 do
    if I in Formats then
    begin
      IconDirectoryEntryes[NeedFormatCount] := FIconDirectoryEntry[I];
      Inc(NeedFormatCount);
    end;
  SetLength(IconDirectoryEntryes, NeedFormatCount);

  with IconDir do
  begin
    Reserved := 0;
    wType := RC3_ICON;
    Count := NeedFormatCount;
  end;

  Stream.Write(IconDir, SizeOf(TCursorOrIcon));

  for I := 0 to NeedFormatCount - 1 do
  begin
    if I = 0 then
      IconDirectoryEntryes[I].dwImageOffset :=
        SizeOf(TCursorOrIcon) + NeedFormatCount * SizeOf(TIconDirectoryEntry)
      else
        IconDirectoryEntryes[I].dwImageOffset :=
          IconDirectoryEntryes[I - 1].dwImageOffset +
          IconDirectoryEntryes[I - 1].dwBytesInRes;
    Stream.Write(IconDirectoryEntryes[I], SizeOf(TIconDirectoryEntry));
  end;

  IcoStream := TMemoryStream.Create;
  try
    FPropertyIcon.SaveToStream(IcoStream);
    for I := 0 to FormatCount - 1 do
      if I in Formats then
      begin
        IcoStream.Position := FIconDirectoryEntry[I].dwImageOffset;
        Stream.CopyFrom(IcoStream, FIconDirectoryEntry[I].dwBytesInRes);
    end;
  finally
    IcoStream.Free;
  end;
end;

procedure TCustomIconEx.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if AutoSize then
    if FormatCount > 0 then
      if CurrentFormat >= 0 then
      begin
        AWidth := FIconDirectoryEntry[CurrentFormat].bWidth;
        AHeight := FIconDirectoryEntry[CurrentFormat].bWidth;
      end;
    inherited;
end;

procedure TCustomIconEx.SetCurrentFormat(const Value: Integer);
begin
  if (Value < -1) or (Value >= FormatCount) then
    raise EListError.CreateResFmt(@SListIndexError, [Value]);
  FCurrentFormat := Value;
  FCurrentBitmapInfo := GetBitmapInfo(FCurrentFormat);
  SetBounds(Left, Top,Width, Height);
  Invalidate;
end;

procedure TCustomIconEx.SetIcon(const Value: TIcon);
begin
  FPropertyIcon.Assign(Value);
end;

procedure TCustomIconEx.CMMouseEnter(var AMsg: TMessage);
begin
  inherited;
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TCustomIconEx.CMMouseLeave(var AMsg: TMessage);
begin
  inherited;
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

end.
