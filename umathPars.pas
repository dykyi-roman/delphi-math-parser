unit umathPars;

interface

type


  TMath = record
  private
    Left  : Double;
    Right : Double;
    Oper  : Char;
  public
    function Calc : string;
  end;

  TOperator   = Set of char;
  TMathParser = record
  const
    inNumber  : set of Char = ['0'..'9', ','];
  private
    FPrepare  : string;
    FText     : string;
    procedure DeleteSpace;
    procedure SetText(const Value: string);
    function  MoveLeft(AText : string; Apos: Word): Integer;
    function  MoveRight(AText: string; APos: Word): Integer;
    procedure ParssPart(var APart: string; AOperator: TOperator);
    function  Parss(APart: string): string;
    function Convert(AText: string): Double;
  public
    Function  ParssString: string;
    property  Text   : string read FText    write SetText;
    property  Prepare: string read FPrepare write FPrepare;
  end;

var
  MathParser : TMathParser;

implementation

uses
  SysUtils, Math;

{ TMathParser }

procedure TMathParser.ParssPart(var APart: string; AOperator: TOperator);
var
  I, l, r: Integer;
  M      : TMath;
  tmp    : Double;
  b      : Boolean;
begin
  i   := 0;
  b   := False;
  while i <  Length(APart) Do
  begin
    If APart[i] in AOperator Then
    begin
      l       := MoveLeft(APart, I) + 1;
      r       := MoveRight(APart, I) - 1;
      M.Oper  := APart[i];
      M.Left  := Convert(Copy(APart,l,I-l));
      M.Right := Convert(Copy(APart,I+1,r-i));

      //Change pozition
      b := (L = 2) and (M.Oper = '+') and (APart[1] = '-');
      If b Then
      begin
         tmp     := M.Left;
         M.Oper  := '-';
         M.Left  := M.Right;
         M.Right := tmp;
      end;

      // For -1 -1 = -1 + -1
      If (L = 2) and (M.Oper = '-' ) and (APart[1] = '-') and (b = false) Then
         M.Oper := '+';

      Delete(APart, l, r-l+1);
      Insert(M.Calc, APart, L);

      // if M.Calc > 0 Then видаляємо попередній знак якщо це +

      i := L;
    end;
  Inc(i);
  end;
end;

function TMathParser.Convert(AText: string): Double;
begin
  TryStrToFloat(AText, Result);
end;

procedure TMathParser.DeleteSpace;
begin
   FText := StringReplace(FText, ' ', '', [rfReplaceAll]);
end;

procedure TMathParser.SetText(const Value: string);
begin
  FText := Value;
  DeleteSpace;
end;

function TMathParser.MoveLeft(AText: string; Apos: Word): Integer;
begin
  Result := Apos - 1;
  While (Result > 0) and (AText[Result] in inNumber) Do
    Dec(Result);
end;

function TMathParser.MoveRight(AText: string; APos: Word): Integer;
begin
  Result := APos + 1;
  While (AText[Result] in inNumber) Do
    Inc(Result);
end;

Function TMathParser.Parss(APart : string): string;
begin
  Result := APart;
  ParssPart(Result, ['^']);
  ParssPart(Result, ['*','/']);
  ParssPart(Result, ['-','+']);
end;

Function TMathParser.ParssString: string;
var
  l, r, i: Integer;
  Part   : string;
begin
  i := Length(FText);
  // find term (...)
  while i > 0 Do
  begin
    If FText[i] = '(' Then
    begin
      l := i;
      For r := l+1 To Length(FText) Do
        If FText[r] = ')' Then
          Break;

      // parss one term
      Part := Parss(Copy(FText,l+1,r-l-1));
      Delete(FText,l,r-l+1);
      Insert(Part,FText, l);
    end;
  Dec(I);
  end;

  // parss text
  Result := Parss(FText);
end;

{ TMath }

function TMath.Calc: String;
var
  tmp : Double;
begin
  Case Oper Of
    '^': tmp := Round(Power(Left, Right));
    '+': tmp := Left + Right;
    '-': tmp := Left - Right;
    '/':
      begin
        If Right = 0 Then
          tmp := 0
        else
          tmp := Left / Right;
      end;
    '*': tmp := Left * Right;
  End;
  Result := FloatToStr(tmp);
end;

end.
