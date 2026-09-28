unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.Shell.ShellCtrls, Vcl.ExtDlgs, Vcl.ExtCtrls,
  Vcl.StdCtrls, WinApi.ShellAPI, IconEx, Vcl.Menus;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Button1: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    Button2: TButton;
    IconEx1: TIconEx;
    GroupBox3: TGroupBox;
    ListBox1: TListBox;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    StatusBar1: TStatusBar;
    GroupBox4: TGroupBox;
    Image1: TImage;
    CheckBox1: TCheckBox;
    SaveDialog1: TSaveDialog;
    ComboBox1: TComboBox;
    Label2: TLabel;
    Button4: TButton;
    SaveDialog2: TSaveDialog;
    PopupMenu1: TPopupMenu;
    Export1: TMenuItem;
    Exportall1: TMenuItem;
    N1: TMenuItem;
    ExportSymbolBitmap1: TMenuItem;
    CheckBox2: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    ComboBox2: TComboBox;
    ExportallSymbolsBitmap1: TMenuItem;
    procedure Button2Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Export1Click(Sender: TObject);
    procedure Exportall1Click(Sender: TObject);
    procedure ExportSymbolBitmap1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ExportallSymbolsBitmap1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);

  private
    { Private-Deklarationen }
    FSplitFileSize: Int64;
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  IconSave;

  // removing file
function DeleteFile(const AFile: string): boolean;
var
 sh: SHFileOpStruct;
begin
 ZeroMemory(@sh, sizeof(sh));
 with sh do
   begin
   Wnd := Application.Handle;
   wFunc := fo_Delete;
   pFrom := PChar(AFile +#0);
   fFlags := fof_Silent or fof_NoConfirmation;
   end;
 result := SHFileOperation(sh) = 0;
end;

// converting icon file format to bitmap file format
procedure ConvertIconToBitmap(const InIconPath, OutBmpPath: string);
var
  Icon: TIcon;
  Bitmap : TBitmap;
begin
  Icon := TIcon.Create;
  Bitmap := TBitmap.Create;
  try
    // Determine the bits per pixel of the bitmap.
      case Form1.ComboBox1.ItemIndex of
        1 : Bitmap.PixelFormat := pf4bit;
        2 : Bitmap.PixelFormat := pf8bit;
        3 : Bitmap.PixelFormat := pf24bit;
        4 : Bitmap.PixelFormat := pf32bit;
      end;
    // Draw the bitmap transparent (white).
      if Form1.CheckBox1.Checked = true then
      begin
        Bitmap.TransparentColor := clWhite;
        Bitmap.Transparent := true;
      end;
    // 1. Load icon
    Icon.LoadFromFile(InIconPath);
    // 2. Adjust bitmap dimensions to the icon
    Bitmap.Width := Icon.Width;
    Bitmap.Height := Icon.Height;
    // 3. Draw the icon onto the bitmap.
    Bitmap.Canvas.Draw(0, 0, Icon);
    // 4. Save as BMP file
    Bitmap.SaveToFile(OutBmpPath);
  finally
    Bitmap.Free;
    Icon.Free;
  end;
end;

// converting icon format to bitmap format
procedure IconToBitmap(const AIcon: TIcon; ABitmap: TBitmap);
begin
  // No icon data, then discard.
  if not Assigned(AIcon) or not Assigned(ABitmap) then Exit;

  // bitmap dimensions
  ABitmap.Width := AIcon.Width;
  ABitmap.Height := AIcon.Height;

  // Optional: Set a background color if your icon relies on alpha transparency
  ABitmap.Canvas.Brush.Color := clWindow;
  ABitmap.Canvas.FillRect(Rect(0, 0, ABitmap.Width, ABitmap.Height));

  // Draw the icon directly onto the bitmap canvas
  ABitmap.Canvas.Draw(0, 0, AIcon);
end;

// converting icon file format to bitmap alpha channel format
procedure ConvertIconToBitmapAlpha(const AIcon: TIcon; ABitmap: TBitmap);
begin
  // // No icon data, then discard.
  if not Assigned(AIcon) or not Assigned(ABitmap) then Exit;

  // Initialize bitmap specs to handle 32-bit alpha layers
  ABitmap.PixelFormat := pf32bit;
  ABitmap.AlphaFormat := afDefined;

  // bitmap dimensions
  ABitmap.Width := AIcon.Width;
  ABitmap.Height := AIcon.Height;

  // Assigning the graphic forces Delphi to copy the underlying image bits properly
  ABitmap.Assign(AIcon);
end;

// Determine the exact size of a file as a decimal number.
function GetFileSize(const AFile: string): Int64;
var
  SR: TSearchRec;
begin
  if FindFirst(AFile, 0, SR) = 0 then
  begin
    { Int64Rec is an advanced structure (a so-called record) used to split a
      64-bit integer (Int64) into its two 32-bit halves: a low part (Lo) and
      a high part (Hi). }
    Int64Rec(Result).Lo := SR.FindData.nFileSizeLow;
    Int64Rec(Result).Hi := SR.FindData.nFileSizeHigh;
    System.SysUtils.FindClose(SR);
  end else
    Result := -1;
end;

// Save container option with icon size selection
procedure TForm1.Button2Click(Sender: TObject);
var
  i: Byte;
  Formats: TIconExFormatSet;
begin
  Form2 := TForm2.Create(self);
  try
    // Determination of symbol sizes within the container
    for i := 0 to IconEx1.FormatCount - 1 do
    begin
      Form2.CheckListBox1.Items.Add(Format('%dx%d, bit %d ',
        [ IconEx1.IconFormats[I].bWidth, IconEx1.IconFormats[I].bHeight,
      IconEx1.IconFormats[I].wBitCount ]));
      Form2.CheckListBox1.Checked[I] := True;
    end;

    // Saving the icon container
    if Form2.ShowModal = mrOk then
    begin
      Formats := [];
        for I := 0 to IconEx1.FormatCount - 1 do
          if Form2.CheckListBox1.Checked[I] then Include(Formats, I);
            if SavePictureDialog1.Execute then
              IconEx1.SaveToFile(SavePictureDialog1.FileName, Formats);
    end;

  finally
    Form2.Free;
  end;
end;

// delete and clear everything
procedure TForm1.Button4Click(Sender: TObject);
begin
  TrackBar1.Position := 0;
  IconEx1.Icon.Assign(nil);
  ListBox1.Clear;
  Image1.Picture.Graphic := nil;
  Label1.Caption := '0x0, bit 0';
end;

// Selection of examples
procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.Checked = true then
  begin
    ExportallSymbolsBitmap1.Enabled := false;
  end else begin
    ExportallSymbolsBitmap1.Enabled := true;
  end;
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
var
  i : integer;
begin
  ListBox1.Clear;
  case ComboBox2.ItemIndex of
    0 : begin
          IconEx1.Icon.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Examples\Notepad.ico');
          FSplitFileSize := GetFileSize(ExtractFilePath(Application.ExeName) + 'Examples\Notepad.ico');
          StatusBar1.Panels[5].Text := Format('%.0n bytes', [FSplitFileSize * 1.0]);
          StatusBar1.Panels[1].Text := 'Adobe-Photoshop.ico';
          StatusBar1.Panels[3].Text := IntToStr(ListBox1.Items.Count);
        end;
    1 : begin
          IconEx1.Icon.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Examples\Adobe-Photoshop.ico');
          FSplitFileSize := GetFileSize(ExtractFilePath(Application.ExeName) + 'Examples\Adobe-Photoshop.ico');
          StatusBar1.Panels[5].Text := Format('%.0n bytes', [FSplitFileSize * 1.0]);
          StatusBar1.Panels[1].Text := 'Adobe-Photoshop.ico';
          StatusBar1.Panels[3].Text := IntToStr(ListBox1.Items.Count);
        end;
    2 : begin
          IconEx1.Icon.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Examples\Computer.ico');
          FSplitFileSize := GetFileSize(ExtractFilePath(Application.ExeName) + 'Examples\Computer.ico');
          StatusBar1.Panels[5].Text := Format('%.0n bytes', [FSplitFileSize * 1.0]);
          StatusBar1.Panels[1].Text := 'Computer.ico';
          StatusBar1.Panels[3].Text := IntToStr(ListBox1.Items.Count);
        end;
    3 : begin
          IconEx1.Icon.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Examples\Earth.ico');
          FSplitFileSize := GetFileSize(ExtractFilePath(Application.ExeName) + 'Examples\Earth.ico');
          StatusBar1.Panels[5].Text := Format('%.0n bytes', [FSplitFileSize * 1.0]);
          StatusBar1.Panels[1].Text := 'Computer.ico';
          StatusBar1.Panels[3].Text := IntToStr(ListBox1.Items.Count);
        end;
    4 : begin
          IconEx1.Icon.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Examples\Linux.ico');
          FSplitFileSize := GetFileSize(ExtractFilePath(Application.ExeName) + 'Examples\Linux.ico');
          StatusBar1.Panels[5].Text := Format('%.0n bytes', [FSplitFileSize * 1.0]);
          StatusBar1.Panels[1].Text := 'Computer.ico';
          StatusBar1.Panels[3].Text := IntToStr(ListBox1.Items.Count);
        end;
    5 : begin
          IconEx1.Icon.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Examples\Monitors.ico');
          FSplitFileSize := GetFileSize(ExtractFilePath(Application.ExeName) + 'Examples\Monitors.ico');
          StatusBar1.Panels[5].Text := Format('%.0n bytes', [FSplitFileSize * 1.0]);
          StatusBar1.Panels[1].Text := 'Computer.ico';
          StatusBar1.Panels[3].Text := IntToStr(ListBox1.Items.Count);
        end;
    6 : begin
          IconEx1.Icon.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Examples\Windows.ico');
          FSplitFileSize := GetFileSize(ExtractFilePath(Application.ExeName) + 'Examples\Windows.ico');
          StatusBar1.Panels[5].Text := Format('%.0n bytes', [FSplitFileSize * 1.0]);
          StatusBar1.Panels[1].Text := 'Computer.ico';
          StatusBar1.Panels[3].Text := IntToStr(ListBox1.Items.Count);
        end;
    7 : begin
          IconEx1.Icon.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Examples\Star.ico');
          FSplitFileSize := GetFileSize(ExtractFilePath(Application.ExeName) + 'Examples\Star.ico');
          StatusBar1.Panels[5].Text := Format('%.0n bytes', [FSplitFileSize * 1.0]);
          StatusBar1.Panels[1].Text := 'Computer.ico';
          StatusBar1.Panels[3].Text := IntToStr(ListBox1.Items.Count);
        end;
  end;

  // Copying the symbol into the image
  Image1.Picture.Icon.Assign(IconEx1.Icon);
  // Pass the number of symbols in the container to the TrackBar.
  TrackBar1.Max := IconEx1.FormatCount - 1;
  TrackBar1.Position := IconEx1.CurrentFormat;

  // Determine which symbol is currently active.
  for i := 0 to IconEx1.FormatCount - 1 do
    begin
      ListBox1.Items.Add(Format(' %dx%d, bit %d ',
        [ IconEx1.IconFormats[i].bWidth, IconEx1.IconFormats[i].bHeight,
      IconEx1.IconFormats[I].wBitCount ]));
  end;
end;

// Saving a symbol from the container
procedure TForm1.Export1Click(Sender: TObject);
var
  i: Byte;
  Formats: TIconExFormatSet;
begin
  if ListBox1.ItemIndex = -1 then
  begin
    Beep;
    MessageDlg('Select Symbol!',mtInformation, [mbOK], 0);
    Exit;
  end;

  if SaveDialog2.Execute then
  begin
    // Determine the symbol to be exported and save them as icon
    Include(Formats, ListBox1.ItemIndex);
    IconEx1.SaveToFile(SaveDialog2.FileName + '.ico', Formats);
  end;
end;

// Export all symbols from the container as an icon file.
procedure TForm1.Exportall1Click(Sender: TObject);
var
  i: Byte;
  Formats: TIconExFormatSet;
  a : integer;
begin
  if SaveDialog2.Execute then
  begin
    // Process all entries and save them as icons.
    for a := ListBox1.Items.Count -1 downto 0 do
    begin
      Include(Formats, a);
      IconEx1.SaveToFile(SaveDialog2.FileName + IntToStr(a) + '.ico', Formats);
    end;
  end;
end;

procedure TForm1.ExportallSymbolsBitmap1Click(Sender: TObject);
var
  i: Byte;
  Formats: TIconExFormatSet;
  bmp : TBitmap;
  a : integer;
begin
  if SaveDialog2.Execute then
  BEGIN
     for a := ListBox1.Items.Count -1 downto 0 do
     begin
      try
        // Determine the resolution of the symbol icon.
        Include(Formats, a);

        // Create the icon file format.
        // To avoid any loss of pixel quality, it is better to save the icon.
        IconEx1.SaveToFile(SaveDialog2.FileName + IntToStr(a) + '.ico', Formats);

        // Convert the icon to a bitmap file format.
        ConvertIconToBitmap(SaveDialog2.FileName + IntToStr(a) + '.ico',
                                SaveDialog2.FileName + IntToStr(a) + '.bmp');
      finally
        // Remove the icon file.
        DeleteFile(SaveDialog2.FileName + IntToStr(a) + '.ico');
        bmp.Free;
      end;

     end;
  END;
end;

// Export a symbol from the container and save it as a bitmap file.
procedure TForm1.ExportSymbolBitmap1Click(Sender: TObject);
var
  i: Byte;
  Formats: TIconExFormatSet;
  bmp : TBitmap;
begin
  if ListBox1.ItemIndex = -1 then
  begin
    Beep;
    MessageDlg('Select Symbol!',mtInformation, [mbOK], 0);
    Exit;
  end;

  if SaveDialog2.Execute then
  begin
    try
      // Determine the resolution of the symbol icon.
      Include(Formats, ListBox1.ItemIndex);

      // Create the icon file format.
      // To avoid any loss of pixel quality, it is better to save the icon.
      IconEx1.SaveToFile(SaveDialog2.FileName + '.ico', Formats);

      if CheckBox2.Checked = false then
      begin
        // Convert the icon to a bitmap file format.
        ConvertIconToBitmap(SaveDialog2.FileName + '.ico', SaveDialog2.FileName + '.bmp');
      end else begin
        // Convert with alpha channel
        try
          bmp := TBitmap.Create;
          IconToBitmap(IconEx1.Icon, bmp);
          ConvertIconToBitmapAlpha(IconEx1.Icon, bmp);
          bmp.SaveToFile(SaveDialog2.FileName + '.bmp');
        except
          on E: Exception do
            ShowMessage(E.Message);
        end;
        bmp.Free; // only if the CheckBox is false
      end;
    finally
      // Remove the icon file.
      DeleteFile(SaveDialog2.FileName + '.ico');
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i : integer;
begin
  DoubleBuffered := true;

  // Prevents focus when adjusting the TrackBar.
  SendMessage(TrackBar1.Handle, WM_UPDATEUISTATE,
                                UIS_CLEAR shl 16 or
                                UISF_HIDEFOCUS, 0);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ComboBox2.OnChange(sender);
  StatusBar1.Panels[3].Text := IntToStr(ListBox1.Items.Count);
end;

// Pass the position to the TrackBar as the ListIndex.
procedure TForm1.ListBox1Click(Sender: TObject);
begin
  TrackBar1.Position := ListBox1.ItemIndex;
end;

// Show the correct symbol from the container.
procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  IconEx1.CurrentFormat := TrackBar1.Position;
  Label1.Caption := Format('%dx%d, bit %d ',
    [
      IconEx1.IconFormats[IconEx1.CurrentFormat].bWidth,
      IconEx1.IconFormats[IconEx1.CurrentFormat].bHeight,
      IconEx1.IconFormats[IconEx1.CurrentFormat].wBitCount
    ]);
end;

// load icon file
procedure TForm1.Button1Click(Sender: TObject);
var
  i : integer;
begin
  if OpenPictureDialog1.Execute then
  begin
    ListBox1.Clear;
    IconEx1.Icon.LoadFromFile(OpenPictureDialog1.FileName);
    Image1.Picture.Icon.Assign(IconEx1.Icon);
    TrackBar1.Max := IconEx1.FormatCount - 1;
    TrackBar1.Position := IconEx1.CurrentFormat;

    for i := 0 to IconEx1.FormatCount - 1 do
    begin
      ListBox1.Items.Add(Format(' %dx%d, ( %d bit ) ',
        [ IconEx1.IconFormats[i].bWidth, IconEx1.IconFormats[i].bHeight,
      IconEx1.IconFormats[I].wBitCount ]));
    end;

    FSplitFileSize := GetFileSize(OpenPictureDialog1.FileName);
    // get file size
    StatusBar1.Panels[5].Text := Format('%.0n bytes', [FSplitFileSize * 1.0]);
    StatusBar1.Panels[1].Text := ExtractFilename(OpenPictureDialog1.FileName);
    StatusBar1.Panels[3].Text := IntToStr(ListBox1.Items.Count);
  end;
end;

end.
