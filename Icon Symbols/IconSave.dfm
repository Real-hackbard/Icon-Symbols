object Form2: TForm2
  Left = 246
  Top = 179
  BorderStyle = bsDialog
  Caption = 'Save *.ico file...'
  ClientHeight = 415
  ClientWidth = 222
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 13
  object btnSave: TButton
    Left = 29
    Top = 376
    Width = 75
    Height = 25
    Caption = 'save'
    ModalResult = 1
    TabOrder = 0
    TabStop = False
  end
  object btnCancel: TButton
    Left = 110
    Top = 376
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'cancel'
    ModalResult = 2
    TabOrder = 1
    TabStop = False
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 24
    Width = 201
    Height = 337
    Caption = ' Select Ico Format '
    TabOrder = 2
    object CheckListBox1: TCheckListBox
      Left = 10
      Top = 22
      Width = 179
      Height = 299
      TabStop = False
      ItemHeight = 17
      TabOrder = 0
    end
  end
end
