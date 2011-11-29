{
    << Impressions >>  U_Visu.pas

    Copyright (C) 2010 - JM.Levecque - <jmarc.levecque@jmlesite.fr>

   This library is a free software coming as a add-on to fpGUI toolkit
   See the copyright included in the fpGUI distribution for details about redistribution

   This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Description:
      This unit is the preview form
}

unit U_Visu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  {$ifdef win32}
  shellapi,
  {$endif}
  fpg_base, fpg_main,
  fpg_form, fpg_panel, fpg_label, fpg_button, fpg_edit, fpg_dialogs, fpg_utils,
  U_Report;

type
  TF_Visu = class(TfpgForm)
    private
      FImprime: T_Imprime;
      Bv_Commande: TfpgBevel;
      Bt_Fermer: TfpgButton;
      Bt_Imprimer: TfpgButton;
      Bt_Imprimante: TfpgButton;
      Bt_Arreter: TfpgButton;
      Bt_Pdf: TfpgButton;
      Bv_Pages: TfpgBevel;
      L_Pages: TfpgLabel;
      Bt_PremPage: TfpgButton;
      Bt_PrecPage: TfpgButton;
      E_NumPage: TfpgEditInteger;
      Bt_SuivPage: TfpgButton;
      Bt_DernPage: TfpgButton;
      L_DePage: Tfpglabel;
      L_NbrPages: TfpgLabel;
      Bv_Sections: TfpgBevel;
      L_Sections: TfpgLabel;
      Bt_PrecSect: TfpgButton;
      E_NumSect: TfpgEditInteger;
      Bt_SuivSect: TfpgButton;
      L_DeSect: Tfpglabel;
      L_NbrSect: TfpgLabel;
      L_PageSect: Tfpglabel;
      L_NumPageSect: Tfpglabel;
      L_DePageSect: TfpgLabel;
      L_NbrPageSect: TfpgLabel;
      procedure FormShow(Sender: TObject);
      procedure Bt_FermerClick(Sender: TObject);
      procedure Bt_ImprimerClick(Sender: TObject);
      procedure Bt_ImprimanteClick(Sender: TObject);
      procedure Bt_ArreterClick(Sender: TObject);
      procedure Bt_PdfClick(Sender: TObject);
      procedure Bt_PremPageClick(Sender: TObject);
      procedure Bt_PrecPageClick(Sender: TObject);
      procedure Bt_SuivPageClick(Sender: TObject);
      procedure Bt_DernPageClick(Sender: TObject);
      procedure Bt_PrecSectClick(Sender: TObject);
      procedure Bt_SuivSectClick(Sender: TObject);
      procedure E_NumPageKeyPress(Sender: TObject; var KeyCode: word; var ShiftState: TShiftState;
                var Consumed: boolean);
      procedure E_NumSectKeyPress(Sender: TObject; var KeyCode: word; var ShiftState: TShiftState;
                var Consumed: boolean);
      procedure ChangeBoutons;
    public
      constructor Create(AOwner: TComponent; AImprime: T_Imprime); reintroduce;
      destructor Destroy; override;
    end;

var
  F_Visu: TF_Visu;
  Bv_Visu: TfpgBevel;

implementation

uses
  U_Command, U_Pdf, U_ReportImages;

procedure TF_Visu.FormShow(Sender: TObject);
begin
L_Pages.Text:= 'Page';
L_Sections.Text:= 'Section';
L_PageSect.Text:= 'Page';
L_DePage.Text:= 'of';
with FImprime do
  begin
  if Sections.Count= 1
  then
    E_NumSect.Focusable:= False;
  if T_Section(Sections[Pred(Sections.Count)]).TotPages= 1
  then
    E_NumPage.Focusable:= False;
  E_NumPage.Text:= IntToStr(NumPage);
  L_NbrPages.Text:= IntToStr(T_Section(Sections[Pred(Sections.Count)]).TotPages);
  E_NumSect.Text:= IntToStr(NumSection);
  L_NbrSect.Text:= IntToStr(Sections.Count);
  L_NumPageSect.Text:= IntToStr(NumPageSection);
  L_NbrPageSect.Text:= IntToStr(T_Section(Sections[Pred(NumSection)]).NbPages);
  ChangeBoutons;
  end;
end;

procedure TF_Visu.Bt_FermerClick(Sender: TObject);
begin
Close;
end;

procedure TF_Visu.Bt_ImprimerClick(Sender: TObject);
begin
end;

procedure TF_Visu.Bt_ImprimanteClick(Sender: TObject);
begin
end;

procedure TF_Visu.Bt_ArreterClick(Sender: TObject);
begin
end;

procedure TF_Visu.Bt_PdfClick(Sender: TObject);
var
  Fd_SauvePdf: TfpgFileDialog;
  FichierPdf: string;
  FluxFichier: TFileStream;
begin
Fd_SauvePdf:= TfpgFileDialog.Create(nil);
Fd_SauvePdf.InitialDir:= ExtractFilePath(Paramstr(0));
Fd_SauvePdf.FontDesc:= 'bitstream vera sans-9';
Fd_SauvePdf.Filter:= 'Fichiers pdf |*.pdf';
Fd_SauvePdf.FileName:= FImprime.DefaultFile;
try
  if Fd_SauvePdf.RunSaveFile
  then
    begin
    FichierPdf:= Fd_SauvePdf.FileName;
    if Lowercase(Copy(FichierPdf,Length(FichierPdf)-3,4))<> '.pdf'
    then
       FichierPdf:= FichierPdf+'.pdf';
    Document:= TPdfDocument.CreateDocument;
    with Document do
      begin
      FluxFichier:= TFileStream.Create(FichierPdf,fmCreate);
      WriteDocument(FluxFichier);
      FluxFichier.Free;
      Free;
      end;
{$ifdef linux}
    fpgOpenURL(FichierPdf);
{$endif}
{$ifdef win32}
    ShellExecute(0,PChar('OPEN'),PChar(FichierPdf),PChar(''),PChar(''),1);
{$endif}
    end;
finally
  Fd_SauvePdf.Free;
  end;
end;

procedure TF_Visu.Bt_PremPageClick(Sender: TObject);
begin
with FImprime do
  begin
  NumPage:= 1;
  NumSection:= 1;
  NumPageSection:= 1;
  E_NumPage.Text:= IntToStr(NumPage);
  Bv_Visu.Visible:= False;
  with T_Section(Sections[Pred(NumSection)]),F_Visu do
    begin
    Bv_Visu.Height:= Paper.H;
    Bv_Visu.Width:= Paper.W;
    Bv_Visu.Top:= 50+(F_Visu.Height-50-Paper.H) div 2;
    Bv_Visu.Left:= (F_Visu.Width-Paper.W) div 2;
    end;
  Bv_Visu.Visible:= True;
  ChangeBoutons;
  E_NumSect.Text:= IntToStr(NumSection);
  L_NumPageSect.Text:= IntToStr(NumPageSection);
  L_NbrPageSect.Text:= IntToStr(T_Section(Sections[Pred(NumSection)]).NbPages);
  end;
end;

procedure TF_Visu.Bt_PrecPageClick(Sender: TObject);
begin
with FImprime do
  begin
  NumPage:= NumPage-1;
  if NumPageSection= 1
  then
    begin
    NumSection:= NumSection-1;
    NumPageSection:= T_Section(Sections[Pred(NumSection)]).NbPages;
    Bv_Visu.Visible:= False;
    with T_Section(Sections[Pred(NumSection)]),F_Visu do
      begin
      Bv_Visu.Height:= Paper.H;
      Bv_Visu.Width:= Paper.W;
      Bv_Visu.Top:= 50+(F_Visu.Height-50-Paper.H) div 2;
      Bv_Visu.Left:= (F_Visu.Width-Paper.W) div 2;
      end;
    Bv_Visu.Visible:= True;
    end
  else
    begin
    NumPageSection:= NumPageSection-1;
    Bv_Visu.Invalidate;
    end;
  E_NumPage.Text:= IntToStr(NumPage);
  ChangeBoutons;
  E_NumSect.Text:= IntToStr(NumSection);
  L_NumPageSect.Text:= IntToStr(NumPageSection);
  L_NbrPageSect.Text:= IntToStr(T_Section(Sections[Pred(NumSection)]).NbPages);
  end;
end;

procedure TF_Visu.Bt_SuivPageClick(Sender: TObject);
begin
with FImprime do
  begin
  NumPage:= NumPage+1;
  if NumPageSection= T_Section(Sections[Pred(NumSection)]).NbPages
  then
    begin
    NumSection:= NumSection+1;
    NumPageSection:= 1;
    Bv_Visu.Visible:= False;
    with T_Section(Sections[Pred(NumSection)]),F_Visu do
      begin
      Bv_Visu.Height:= Paper.H;
      Bv_Visu.Width:= Paper.W;
      Bv_Visu.Top:= 50+(F_Visu.Height-50-Paper.H) div 2;
      Bv_Visu.Left:= (F_Visu.Width-Paper.W) div 2;
      end;
    Bv_Visu.Visible:= True;
    end
  else
    begin
    NumPageSection:= NumPageSection+1;
    Bv_Visu.Invalidate;
    end;
  E_NumPage.Text:= IntToStr(NumPage);
  ChangeBoutons;
  E_NumSect.Text:= IntToStr(NumSection);
  L_NumPageSect.Text:= IntToStr(NumPageSection);
  L_NbrPageSect.Text:= IntToStr(T_Section(Sections[Pred(NumSection)]).NbPages);
  end;
end;

procedure TF_Visu.Bt_DernPageClick(Sender: TObject);
begin
with FImprime do
  begin
  NumPage:= T_Section(Sections[Pred(Sections.Count)]).TotPages;
  NumSection:= Sections.Count;
  NumPageSection:= T_Section(Sections[Pred(Sections.Count)]).NbPages;
  E_NumPage.Text:= IntToStr(NumPage);
  Bv_Visu.Visible:= False;
  with T_Section(Sections[Pred(NumSection)]),F_Visu do
    begin
    Bv_Visu.Height:= Paper.H;
    Bv_Visu.Width:= Paper.W;
    Bv_Visu.Top:= 50+(F_Visu.Height-50-Paper.H) div 2;
    Bv_Visu.Left:= (F_Visu.Width-Paper.W) div 2;
    end;
  Bv_Visu.Visible:= True;
  ChangeBoutons;
  E_NumSect.Text:= IntToStr(NumSection);
  L_NumPageSect.Text:= IntToStr(NumPageSection);
  L_NbrPageSect.Text:= IntToStr(T_Section(Sections[Pred(NumSection)]).NbPages);
  end;
end;

procedure TF_Visu.Bt_PrecSectClick(Sender: TObject);
begin
with FImprime do
  begin
  NumSection:= NumSection-1;
  NumPage:= T_Section(Sections[Pred(NumSection)]).FirstPage;
  NumPageSection:= 1;
  E_NumPage.Text:= IntToStr(NumPage);
  Bv_Visu.Visible:= False;
  with T_Section(Sections[Pred(NumSection)]),F_Visu do
    begin
    Bv_Visu.Height:= Paper.H;
    Bv_Visu.Width:= Paper.W;
    Bv_Visu.Top:= 50+(F_Visu.Height-50-Paper.H) div 2;
    Bv_Visu.Left:= (F_Visu.Width-Paper.W) div 2;
    end;
  Bv_Visu.Visible:= True;
  ChangeBoutons;
  E_NumSect.Text:= IntToStr(NumSection);
  L_NumPageSect.Text:= IntToStr(NumPageSection);
  L_NbrPageSect.Text:= IntToStr(T_Section(Sections[Pred(NumSection)]).NbPages);
  end;
end;

procedure TF_Visu.Bt_SuivSectClick(Sender: TObject);
begin
with FImprime do
  begin
  NumSection:= NumSection+1;
  NumPage:= T_Section(Sections[Pred(NumSection)]).FirstPage;
  NumPageSection:= 1;
  E_NumPage.Text:= IntToStr(NumPage);
  Bv_Visu.Visible:= False;
  with T_Section(Sections[Pred(NumSection)]),F_Visu do
    begin
    Bv_Visu.Height:= Paper.H;
    Bv_Visu.Width:= Paper.W;
    Bv_Visu.Top:= 50+(F_Visu.Height-50-Paper.H) div 2;
    Bv_Visu.Left:= (F_Visu.Width-Paper.W) div 2;
    end;
  Bv_Visu.Visible:= True;
  ChangeBoutons;
  E_NumSect.Text:= IntToStr(NumSection);
  L_NumPageSect.Text:= IntToStr(NumPageSection);
  L_NbrPageSect.Text:= IntToStr(T_Section(Sections[Pred(NumSection)]).NbPages);
  end;
end;

procedure TF_Visu.ChangeBoutons;
begin
with FImprime do
  if T_Section(Sections[Pred(Sections.Count)]).TotPages> 1
  then
    if NumPage= 1
    then
      begin
      Bt_PremPage.Enabled:= False;
      Bt_PrecPage.Enabled:= False;
      Bt_SuivPage.Enabled:= True;
      Bt_DernPage.Enabled:= True;
      Bt_PrecSect.Enabled:= False;
      if Sections.Count> 1
      then
        Bt_SuivSect.Enabled:= True
      else
        Bt_SuivSect.Enabled:= False;
      end
    else
      if NumPage= T_Section(Sections[Pred(Sections.Count)]).TotPages
      then
        begin
        Bt_PremPage.Enabled:= True;
        Bt_PrecPage.Enabled:= True;
        Bt_SuivPage.Enabled:= False;
        Bt_DernPage.Enabled:= False;
        if Sections.Count> 1
        then
          Bt_PrecSect.Enabled:= True
        else
          Bt_PrecSect.Enabled:= False;
        Bt_SuivSect.Enabled:= False;
        end
      else
        begin
        Bt_PremPage.Enabled:= True;
        Bt_PrecPage.Enabled:= True;
        Bt_SuivPage.Enabled:= True;
        Bt_DernPage.Enabled:= True;
        if Sections.Count> 1
        then
          if NumSection= 1
          then
            begin
            Bt_PrecSect.Enabled:= False;
            Bt_SuivSect.Enabled:= True;
            end
          else
            if NumSection= Sections.Count
            then
              begin
              Bt_PrecSect.Enabled:= True;
              Bt_SuivSect.Enabled:= False;
              end
            else
              begin
              Bt_PrecSect.Enabled:= True;
              Bt_SuivSect.Enabled:= True;
              end
        else
          begin
          Bt_PrecSect.Enabled:= False;
          Bt_SuivSect.Enabled:= False;
          end;
        end
  else
    begin
    Bt_PremPage.Enabled:= False;
    Bt_PrecPage.Enabled:= False;
    Bt_SuivPage.Enabled:= False;
    Bt_DernPage.Enabled:= False;
    Bt_PrecSect.Enabled:= False;
    Bt_SuivSect.Enabled:= False;
    end;
end;

procedure TF_Visu.E_NumPageKeyPress(Sender: TObject; var KeyCode: word; var ShiftState: TShiftState;
          var Consumed: boolean);
var
  CptSect,CptPage,CptPageSect: Integer;
begin
if (KeyCode= KeyReturn) or (KeyCode= KeyPEnter)
then
  with FImprime do
    begin
    if E_NumPage.Value> T_Section(Sections[Pred(Sections.Count)]).TotPages
    then
      NumPage:= T_Section(Sections[Pred(Sections.Count)]).TotPages
    else
      if E_NumPage.Value= 0
      then
        NumPage:= 1
      else
        NumPage:= E_NumPage.Value;
    E_NumPage.Value:= NumPage;
    CptSect:= 0;
    CptPage:= 0;
    repeat
      Inc(CptSect);
      CptPageSect:= 0;
      repeat
        Inc(CptPage);
        Inc(CptPageSect);
      until (CptPage= NumPage) or (CptPage= T_Section(Sections[Pred(Cptsect)]).NbPages);
    until CptPage= NumPage;
    NumSection:= CptSect;
    NumPageSection:= CptPagesect;
    Bv_Visu.Invalidate;
    ChangeBoutons;
    E_NumSect.Text:= IntToStr(NumSection);
    L_NumPageSect.Text:= IntToStr(NumPageSection);
    L_NbrPageSect.Text:= IntToStr(T_Section(Sections[Pred(NumSection)]).NbPages);
    end;
end;

procedure TF_Visu.E_NumSectKeyPress(Sender: TObject; var KeyCode: word; var ShiftState: TShiftState;
          var Consumed: boolean);
begin
if (KeyCode= KeyReturn) or (KeyCode= KeyPEnter)
then
  with FImprime do
    begin
    if E_NumSect.Value> Sections.Count
    then
      NumSection:= Sections.Count
    else
    if E_NumSect.Value= 0
    then
      NumSection:= 1
    else
      NumSection:= E_NumSect.Value;
    E_NumSect.Value:= NumSection;
    NumPage:= T_Section(Sections[Pred(NumSection)]).FirstPage;
    NumPageSection:= 1;
    E_NumPage.Value:= NumPage;
    Bv_Visu.Invalidate;
    ChangeBoutons;
    L_NumPageSect.Text:= IntToStr(NumPageSection);
    L_NbrPageSect.Text:= IntToStr(T_Section(Sections[Pred(NumSection)]).NbPages);
    end;
end;

constructor TF_Visu.Create(AOwner: TComponent; AImprime: T_Imprime);
begin
inherited Create(AOwner);
FImprime := AImprime;
Name := 'F_Visu';
WindowTitle:= 'Preview';
WindowPosition:= wpUser;
SetPosition(0, 0, FpgApplication.ScreenWidth-2, FpgApplication.ScreenHeight-66);
Sizeable:= False;
BackgroundColor:= clMediumAquamarine;
CreateReportImages;
Bv_Commande:= CreateBevel(Self,0,0,Width,50,bsBox,bsRaised);
Bv_Commande.BackgroundColor:= clBisque;
Bt_Fermer:= CreateButton(Bv_Commande,10,10,26,'',@Bt_FermerClick,'stdimg.exit');
Bt_Fermer.BackgroundColor:= clOrangeRed;
Bt_Imprimer:= CreateButton(Bv_Commande,50,10,26,'',@Bt_ImprimerClick,'stdimg.print');
Bt_Imprimer.BackgroundColor:= clGreen;
Bt_Imprimer.Enabled:= False;
Bt_Imprimante:= CreateButton(Bv_Commande,90,10,26,'',@Bt_ImprimanteClick,'repimg.Imprimante');
Bt_Imprimante.BackgroundColor:= clSilver;
Bt_Imprimante.Enabled:= False;
Bt_Arreter:= CreateButton(Bv_Commande,130,10,26,'',@Bt_ArreterClick,'repimg.Stop');
Bt_Arreter.BackgroundColor:= clRed;
Bt_Pdf:= CreateButton(Bv_Commande,170,10,26,'',@Bt_PdfClick,'stdimg.Adobe_pdf');
Bt_Pdf.BackgroundColor:= clWhite;
Bt_Pdf.ImageMargin:= 0;
Bv_Pages:= CreateBevel(Bv_Commande,220,5,300,40,bsBox,bsLowered);
Bv_Pages.BackgroundColor:= clLinen;
Bt_PremPage:= CreateButton(Bv_Pages,54,6,26,'',@Bt_PremPageClick,'repimg.Debut');
Bt_PrecPage:= CreateButton(Bv_Pages,80,6,26,'',@Bt_PrecPageClick,'repimg.Precedent');
E_NumPage:= CreateEditInteger(Bv_Pages,110,8,60,0);
E_NumPage.OnKeyPress:= @E_NumPageKeypress;
Bt_Suivpage:= CreateButton(Bv_Pages,174,6,26,'',@Bt_SuivPageClick,'repimg.Suivant');
Bt_DernPage:= CreateButton(Bv_Pages,200,6,26,'',@Bt_DernPageClick,'repimg.Fin');
L_Pages:= CreateLabel(Bv_Pages,5,E_NumPage.Top,'Page',0,E_NumPage.Height,taLeftJustify,tlcenter);
L_Depage:= CreateLabel(Bv_Pages,235,E_NumPage.Top,'de',0,E_NumPage.Height,taLeftJustify,tlcenter);
L_NbrPages:= CreateLabel(Bv_Pages,265,E_NumPage.Top,' ',30,E_NumPage.Height,taCenter,tlcenter);
Bv_Sections:= CreateBevel(Bv_Commande,540,5,500,40,bsBox,bsLowered);
Bv_Sections.BackgroundColor:= clLinen;
Bt_PrecSect:= CreateButton(Bv_Sections,90,6,26,'',@Bt_PrecSectClick,'repimg.Precedent');
E_NumSect:= CreateEditInteger(Bv_Sections,120,8,60,0);
E_NumSect.OnKeyPress:= @E_NumSectKeyPress;
Bt_SuivSect:= CreateButton(Bv_Sections,184,6,26,'',@Bt_SuivSectClick,'repimg.Suivant');
L_Sections:= CreateLabel(Bv_Sections,5,E_NumSect.Top,'Section',0,E_NumSect.Height,taLeftJustify,tlcenter);
L_DeSect:= CreateLabel(Bv_Sections,250,E_NumSect.Top,'of',0,E_NumSect.Height,taLeftJustify,tlcenter);
L_NbrSect:= CreateLabel(Bv_Sections,280,E_NumSect.Top,'-',0,E_NumSect.Height,taLeftJustify,tlcenter);
L_PageSect:= CreateLabel(Bv_Sections,320,E_NumSect.Top,'Page',0,E_NumSect.Height,taLeftJustify,tlcenter);
L_NumPageSect:= CreateLabel(Bv_Sections,365,E_NumSect.Top,'-',0,E_NumSect.Height,taLeftJustify,tlcenter);
L_DePageSect:= CreateLabel(Bv_Sections,410,E_NumSect.Top,'of',0,E_NumSect.Height,taLeftJustify,tlcenter);
L_NbrPageSect:= CreateLabel(Bv_Sections,440,E_NumSect.Top,'-',0,E_NumSect.Height,taLeftJustify,tlcenter);
OnShow:= @FormShow;
end;

destructor TF_Visu.Destroy;
begin
DeleteReportImages;
inherited Destroy;
end;

end.

