object Form1: TForm1
  Left = 428
  Top = 127
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Icon Symbols'
  ClientHeight = 519
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object Label4: TLabel
    Left = 95
    Top = 467
    Width = 51
    Height = 13
    Caption = 'Examples :'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 289
    Height = 297
    Caption = ' Icon View '
    TabOrder = 0
    object IconEx1: TIconEx
      Left = 16
      Top = 22
      Width = 256
      Height = 256
      AutoSize = True
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 320
    Width = 289
    Height = 129
    Caption = ' Show Symbols '
    TabOrder = 1
    object Label1: TLabel
      Left = 48
      Top = 40
      Width = 32
      Height = 13
      Caption = 'Label1'
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 16
      Top = 40
      Width = 26
      Height = 13
      Caption = 'Size :'
    end
    object TrackBar1: TTrackBar
      Left = 16
      Top = 78
      Width = 256
      Height = 20
      TabOrder = 0
      TabStop = False
      ThumbLength = 14
      OnChange = TrackBar1Change
    end
  end
  object Button1: TButton
    Left = 312
    Top = 462
    Width = 75
    Height = 25
    Caption = '&Open'
    TabOrder = 2
    TabStop = False
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 393
    Top = 462
    Width = 75
    Height = 25
    Caption = '&Save'
    TabOrder = 3
    TabStop = False
    OnClick = Button2Click
  end
  object GroupBox3: TGroupBox
    Left = 312
    Top = 8
    Width = 169
    Height = 297
    Caption = ' Symbol Resulotions '
    TabOrder = 4
    object ListBox1: TListBox
      Left = 16
      Top = 22
      Width = 137
      Height = 256
      ItemHeight = 13
      PopupMenu = PopupMenu1
      TabOrder = 0
      OnClick = ListBox1Click
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 500
    Width = 492
    Height = 19
    Panels = <
      item
        Text = 'Icon :'
        Width = 40
      end
      item
        Text = 'Computer.ico'
        Width = 220
      end
      item
        Text = 'Symbols :'
        Width = 60
      end
      item
        Text = '0'
        Width = 30
      end
      item
        Text = 'Size :'
        Width = 40
      end
      item
        Text = '0 kb'
        Width = 50
      end>
    ExplicitTop = 501
    ExplicitWidth = 488
  end
  object GroupBox4: TGroupBox
    Left = 315
    Top = 311
    Width = 169
    Height = 138
    Caption = ' Bitmap Options '
    TabOrder = 6
    object Image1: TImage
      Left = 16
      Top = 32
      Width = 49
      Height = 49
      AutoSize = True
    end
    object Label2: TLabel
      Left = 71
      Top = 32
      Width = 18
      Height = 13
      Caption = 'Bit :'
    end
    object CheckBox1: TCheckBox
      Left = 71
      Top = 73
      Width = 80
      Height = 17
      TabStop = False
      Caption = 'Transparent'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object ComboBox1: TComboBox
      Left = 95
      Top = 29
      Width = 58
      Height = 21
      Style = csDropDownList
      ItemIndex = 2
      TabOrder = 1
      TabStop = False
      Text = '24'
      Items.Strings = (
        '4'
        '8'
        '24'
        '32')
    end
    object CheckBox2: TCheckBox
      Left = 71
      Top = 104
      Width = 93
      Height = 17
      Hint = 'Extra data layer that controls pixel-level transparency'
      TabStop = False
      Caption = 'Alpha Channel'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = CheckBox2Click
    end
  end
  object Button4: TButton
    Left = 8
    Top = 462
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 7
    TabStop = False
    OnClick = Button4Click
  end
  object ComboBox2: TComboBox
    Left = 152
    Top = 464
    Width = 121
    Height = 21
    Style = csDropDownList
    ItemIndex = 2
    TabOrder = 8
    TabStop = False
    Text = 'Computer'
    OnChange = ComboBox2Change
    Items.Strings = (
      'Notepad'
      'Adobe-Photoshop'
      'Computer'
      'Earth'
      'Linux'
      'Monitors'
      'Windows'
      'Star')
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 'Icons (*.ico)|*.ico'
    Left = 72
    Top = 64
  end
  object SavePictureDialog1: TSavePictureDialog
    DefaultExt = 'ico'
    Filter = 'Icons (*.ico)|*.ico'
    Left = 192
    Top = 72
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Bitmap (*.bmp)|*.bmp'
    Left = 56
    Top = 144
  end
  object SaveDialog2: TSaveDialog
    Left = 152
    Top = 144
  end
  object PopupMenu1: TPopupMenu
    Left = 232
    Top = 136
    object Export1: TMenuItem
      Caption = 'Export Symbol'
      OnClick = Export1Click
    end
    object Exportall1: TMenuItem
      Caption = 'Export all Symbols'
      OnClick = Exportall1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ExportSymbolBitmap1: TMenuItem
      Caption = 'Export Symbol Bitmap'
      OnClick = ExportSymbolBitmap1Click
    end
    object ExportallSymbolsBitmap1: TMenuItem
      Caption = 'Export all Symbols Bitmap'
      OnClick = ExportallSymbolsBitmap1Click
    end
  end
end
