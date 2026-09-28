unit IconExReg;

interface

uses
  Windows, Classes, SysUtils, Controls, TypInfo, Graphics, 
  {$IFDEF VER130}
    DsgnIntf
  {$ELSE}
    DesignIntf, DesignEditors, VCLEditors
  {$ENDIF},
  IconEx;

type

  TCurrentFormatProperty = class(TIntegerProperty)
  protected
    function GetIconEx: TIconEx;
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;


procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Fangorn Wizards Lab', [TIconEx]);
  RegisterPropertyEditor(TypeInfo(Integer), TIconEx,
    'CurrentFormat', TCurrentFormatProperty);
end;


{ TCurrentFormatProperty }

function TCurrentFormatProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList];
end;

function TCurrentFormatProperty.GetIconEx: TIconEx;
begin
  try
    Result := GetComponent(0) as TIconEx;
  except
    Result := nil;
  end;
end;

function TCurrentFormatProperty.GetValue: string;
var
  CurValue: Longint;
  AComponent: TIconEx;
begin
  AComponent := GetIconEx;
  if AComponent = nil then Exit;
  CurValue := GetOrdValue;
  if CurValue = -1 then
    Result := '-1: No image'
  else
    Result := Format('%d: %dx%d, color %d',
      [CurValue, AComponent.IconFormats[CurValue].bWidth,
      AComponent.IconFormats[CurValue].bHeight,
      AComponent.IconFormats[CurValue].wBitCount]);
end;

procedure TCurrentFormatProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  AComponent: TIconEx;
begin
  AComponent := GetIconEx;
  if AComponent = nil then Exit;
  Proc('-1: No image');
  for I := 0 to AComponent.FormatCount - 1 do
    Proc(Format('%d: %dx%d, color %d',
      [I, AComponent.IconFormats[I].bWidth,
      AComponent.IconFormats[I].bHeight,
      AComponent.IconFormats[I].wBitCount]));
end;

procedure TCurrentFormatProperty.SetValue(const Value: string);
var
  TmpS: String;
  TmpVal: Integer;
  AComponent: TIconEx;
begin
  AComponent := GetIconEx;
  if AComponent = nil then Exit;
  TmpS := Copy(Value, 1, Pos(':', Value) - 1);
  if TryStrToInt(TmpS, TmpVal) then
    inherited SetOrdValue(TmpVal)
  else
    inherited SetOrdValue(-1);
end;

end.
