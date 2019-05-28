unit TMySettingsUnit;

interface

uses
  Menus,  // Add Recent Menu

  TGenObjectUnit,     // TGenObject
  T3dfxTypesUnit;
  
{$IFDEF DEFDEBUG}
type TMySettings = class(TGenObject)
{$ELSE}
type TMySettings = class(TObject)
{$ENDIF}
  protected

    // Resolution Factor (from 0.3 - 1.0)

    objResolution : single;

    // Main Windows Setting

    objWinLeft    : integer;
    objWinWidth   : integer;
    objWinTop     : integer;
    objWinHeight  : integer;

    // Texture Window

    objTextureWdt : integer;

    // Property Frames

    objSceneOn      : boolean;
    objSceneHeigth  : integer;
    objListOn       : boolean;
    objListHeigth   : integer;
    objPropOn       : boolean;
    objPropHeight   : integer;
    objTrackingOn   : boolean;
    objTrackType    : integer;
    objLogOn        : boolean;

    // Current Scene Name

    objSceneFile : string;

    // Common Document Folder

    objComFolder : string;

    // Recent Scenes

    objRecent : array [0..8] of string;

    function  GetHintOnInt: boolean;
    procedure SetHintOnInt(const Value : boolean);

    procedure OnRecent(Sender: TObject);
  public
    constructor Create;
    destructor  Destroy; override;

    procedure LoadFromFile;
    procedure SaveToFile;

    procedure AddRecentMenu(const MenuItem : TMenuItem);

    procedure AddRecentScene(const FileName : string);

    // Startup and Shutdown

    class procedure AppSettingsStartup;
    class procedure AppSettingsShutDown;

    // Main Windows Setting

    property pWinLeft   : integer read objWinLeft    write objWinLeft;
    property pWinWidth  : integer read objWinWidth   write objWinWidth;
    property pWinTop    : integer read objWinTop     write objWinTop;
    property pWinHeight : integer read objWinHeight  write objWinHeight;

    property pResolution : single read objResolution write objResolution;
    
    // Texture Window

    property pTextureWdt  : integer read objTextureWdt write objTextureWdt;

    // Property Frames

    property pSceneOn     : boolean read objSceneOn      write objSceneOn;
    property pSceneHeigth : integer read objSceneHeigth  write objSceneHeigth;
    property pListOn      : boolean read objListOn       write objListOn;
    property pListHeigth  : integer read objListHeigth   write objListHeigth;
    property pPropOn      : boolean read objPropOn       write objPropOn;
    property pPropHeight  : integer read objPropHeight   write objPropHeight;
    property pTrackingOn  : boolean read objTrackingOn   write objTrackingOn;
    property pTrackType   : integer read objTrackType    write objTrackType;
    property pLogOn       : boolean read objLogOn        write objLogOn;

    // Application Hint

    property pHintOn     : boolean read GetHintOnInt write SetHintOnINt;

    // Current Scene

    property pSceneFile  : string  read objSceneFile write objSceneFile;

    // Common Document Folder

    property pComFolder  : string  read objComFolder write objComFolder;
end;

//------------------------------------------------------------------------------
// Free Functions
//------------------------------------------------------------------------------

var AppSettings : TMySettings;

implementation

uses
  SysUtils,
  Forms,
  StrUtils,
  
  T3dfxGeometryUnit,    // Math Function
  TGenStrUnit,          // String Functions
  T3dfxStrUnit,         // String Functions
  TResStringUnit,       // Resource Strings
  T3dfxGuiUnit,         // Gui Functions
  TGenIniFileUnit,      // Ini File

  T3dfxBaseUnit,          // Sub Base Class
  T3dfxSceenUnit,         // Current Scene
  T3dfxSceneFactoryUnit,  // Scene Factory
  T3dfxObjectFileUnit,    // Load Save Scene
  TGenPickFolderUnit,     // Select a Folder
  T3dfxScenePickUnit,     // Pick a Scene
  TGenTextFileUnit,       // File Functions
  TGenClassesUnit;        // Class Definitions

//------------------------------------------------------------------------------
//  Ini File Constants
//------------------------------------------------------------------------------
const
  Prf            = 'Application';

  // Main Windows Setting

  PrfWinLeft     = 'WinLeft';
  PrfWinWidth    = 'WinWidth';
  PrfWinTop      = 'WinTop';
  PrfWinHeight   = 'WinHeight';
  PrfResolution  = 'Resolution';

  // Texture Window

  PrfTextureWdt  = 'TextureWdt';

  // Property Frames

  PrfSceneOn     = 'SceneOn';
  PrfSceneHeigth = 'SceneHeigth';
  PrfListOn      = 'ListOn';
  PrfListHeigth  = 'ListHeigth';
  PrfPropOn      = 'PropOn';
  PrfPropHeight  = 'PropHeight';
  PrfLightsOn    = 'LightsOn';
  PrfTrackingOn  = 'TrackingOn';
  PrfTrackType   = 'TrackingType';
  PrfLogOn       = 'LogOn';

  // Application Hint

  PrfHintOn      = 'HintOn';

  // Current Scene Name

  PrfScene       = 'Scene';

  // Common Document Folder

  PrfComFolder   = 'ComFolder';

  // Recent Scenes

  PrfRecent      = 'Recent';

//------------------------------------------------------------------------------
// Create
//------------------------------------------------------------------------------
constructor TMySettings.Create;
var
  Ind : integer;
begin
  inherited Create;

  objResolution := 1.0;

  // Main Windows Setting

  objWinLeft    := 10;
  objWinWidth   := 600;
  objWinTop     := 20;
  objWinHeight  := 500;

  // Texture Window

  objTextureWdt := 200;

  // Property Frames

  objSceneOn     := true;
  objSceneHeigth := 60;
  objListOn      := true;
  objListHeigth  := 60;
  objPropOn      := true;
  objPropHeight  := 60;
  objTrackingOn  := false;
  objTrackType   := -1;
  objLogOn       := false;

  // Current Scene Name

  objSceneFile := '';

  // Common Document Folder

  objComFolder := '';

  // Recent Scenes

  for Ind := 0 to length(objRecent) - 1 do objRecent[Ind] := '';

  LoadFromFile;
end;
//------------------------------------------------------------------------------
// Destroy
//------------------------------------------------------------------------------
destructor TMySettings.Destroy;
begin
  SaveToFile;

  inherited Destroy;
end;
//------------------------------------------------------------------------------
// Load Settings from File
//------------------------------------------------------------------------------
procedure TMySettings.LoadFromFile;
var
  fIni : TGenIniFile;
  Ind  : integer;
begin

  // Open Ini File

  if IsFile(ApplicationIniFile) then
    begin
      // Open the Ini file and store some stuff

      fIni := TGenIniFile.Create;

      // Main Windows Setting

      objResolution := fIni.ReadFloat(Prf, PrfResolution,   objResolution);

      objWinLeft    := fIni.ReadInteger(Prf, PrfWinLeft,   objWinLeft);
      objWinWidth   := fIni.ReadInteger(Prf, PrfWinWidth,  objWinWidth);
      objWinTop     := fIni.ReadInteger(Prf, PrfWinTop,    objWinTop);
      objWinHeight  := fIni.ReadInteger(Prf, PrfWinHeight, objWinHeight);

      // Texture Window

      objTextureWdt := fIni.ReadInteger(Prf, PrfTextureWdt, objTextureWdt);

      // Property Frames

      objSceneOn     := fIni.ReadBool   (Prf,PrfSceneOn,     objSceneOn);
      objSceneHeigth := fIni.ReadInteger(Prf,PrfSceneHeigth, objSceneHeigth);
      objListOn      := fIni.ReadBool   (Prf,PrfListOn,      objListOn);
      objListHeigth  := fIni.ReadInteger(Prf,PrfListHeigth,  objListHeigth);
      objPropOn      := fIni.ReadBool   (Prf,PrfPropOn,      objPropOn);
      objPropHeight  := fIni.ReadInteger(Prf,PrfPropHeight,  objPropHeight);
      objTrackingOn  := fIni.ReadBool   (Prf,PrfTrackingOn,  objTrackingOn);
      objTrackType   := fIni.ReadInteger(Prf,PrfTrackType,   objTrackTYpe);
      objLogOn       := fIni.ReadBool   (Prf,PrfLogOn,       objLogOn);

      // Application Hint

      self.pHintOn := fIni.ReadBool(Prf, PrfHintOn, true);

      // A) Common Document Folder

      objComFolder := fIni.ReadString(Prf, PrfComFolder, objComFolder);
      if not IsFolder(objComFolder) then
        begin
          objComFolder := TGenPickFolder.PickFolder('', Str(rsAppComFolder));
        end;

      // B) Current Scene Name

      objSceneFile := fIni.ReadString(Prf, PrfScene, objSceneFile);
      (*if not IsFile(objSceneFile) then
        begin
          sTmp := ResolveFileName(objSceneFile);
          if IsFolder(sTmp) then
            objSceneFile := sTmp
          else
            objSceneFile := PickScene(objComFolder);
        end; *)

      // Recent Scenes

      for Ind := 0 to length(objRecent) - 1 do
        objRecent[Ind] := fIni.ReadString(Prf, PrfRecent + IntToStr(Ind), '');

      fIni.Free;
    end

end;

//------------------------------------------------------------------------------
// Save Settings to File
//------------------------------------------------------------------------------
procedure TMySettings.SaveToFile;
var
  fIni : TGenIniFile;
  Ind  : integer;
begin

  fIni := TGenIniFile.Create;

  // Main Windows Setting

  fIni.WriteFloat(Prf, PrfResolution,   objResolution);

  fIni.WriteInteger(Prf, PrfWinLeft,   objWinLeft);
  fIni.WriteInteger(Prf, PrfWinWidth,  objWinWidth);
  fIni.WriteInteger(Prf, PrfWinTop,    objWinTop);
  fIni.WriteInteger(Prf, PrfWinHeight, objWinHeight);

  // Texture Window

  fIni.WriteInteger(Prf, PrfTextureWdt, objTextureWdt);

  // Property Frames

  fIni.WriteBool   (Prf,PrfSceneOn,     objSceneOn);
  fIni.WriteInteger(Prf,PrfSceneHeigth, objSceneHeigth);
  fIni.WriteBool   (Prf,PrfListOn,      objListOn);
  fIni.WriteInteger(Prf,PrfListHeigth,  objListHeigth);
  fIni.WriteBool   (Prf,PrfPropOn,      objPropOn);
  fIni.WriteInteger(Prf,PrfPropHeight,  objPropHeight);
  fIni.WriteBool   (Prf,PrfTrackingOn,  objTrackingOn);
  fIni.WriteInteger(Prf,PrfTrackType,   objTrackTYpe);
  fIni.WriteBool   (Prf,PrfLogOn,       objLogOn);

  // Application Hint

  fIni.WriteBool(Prf, PrfHintOn, GetHintOnInt);

  // Current Scene Name

  fIni.WriteString(Prf, PrfScene, objSceneFile);

  // Common Document Folder

  fIni.WriteString(Prf, PrfComFolder, objComFolder);

  // Recent Scenes

  for Ind := 0 to length(objRecent) - 1 do
    if length(objRecent[Ind]) > 0 then
      fIni.WriteString(Prf, PrfRecent + IntToStr(Ind), objRecent[Ind]);

  fIni.Free;
end;
//------------------------------------------------------------------------------
//  Add recent Sub Menu
//------------------------------------------------------------------------------
procedure TMySettings.AddRecentMenu(const MenuItem : TMenuItem);
var
  NewMenu : TMenuItem;
  Ind     : integer;
begin
  if (MenuItem <> nil) then
    begin
      MenuItem.Clear;

      for Ind := 0 to length(objRecent) - 1 do
        if (length(objRecent[Ind]) > 0) then
          begin
            NewMenu := TMenuItem.Create(MenuItem);
            NewMenu.Caption := StripFileExt(objRecent[Ind]);

            NewMenu.OnClick := OnRecent;
            MenuItem.Add(NewMenu);
         end;
    end;
end;
//------------------------------------------------------------------------------
//  Perform a Menu Command
//------------------------------------------------------------------------------
procedure TMySettings.OnRecent(Sender: TObject);
var
  sName : string;
begin
  if (Sender <> nil) and (Sender is TMenuItem) then
    begin
      sName := TMenuItem(Sender).Caption;
      SceneFactory.SceneLoadFromFile(sName + fpSceenExt);
    end;
end;
//------------------------------------------------------------------------------
//  Add Recent Scene
//------------------------------------------------------------------------------
procedure TMySettings.AddRecentScene(const FileName : string);
var
  Ind      : integer;
  IndExist : integer;
begin
  if (length(FileName) > 0) then
    begin
      // This should be placed at the top (0)

      // Find out if it exists already

      IndExist := -1;
      for Ind := 0 to length(objRecent) - 1 do
        begin
          if IsSameFileName(FileName, objRecent[Ind]) then
            begin
              IndExist := Ind;

              //Log('Found ' + FileName + ' At ' + ToStr(IndExist));
              break;
            end;
        end;

      // Did we get it and is it the first already

      if (IndExist > 0) and (IndExist <> 0) then
        begin
          // Walk from back and move all up from IndIndex

          for Ind := (IndExist - 1) downto 0 do
            begin
              objRecent[Ind + 1] := objRecent[Ind];

              //Log('Move1 ' + objRecent[Ind] + ' From ' + ToStr(Ind) +
              //                                ' To ' + ToStr(Ind+1));
            end;

          // Add it at index 0

          objRecent[0] := FileName;
        end
      else if (IndExist <> 0) then
        begin
          // Walk from Back and move all (but last) up one index

          for Ind := length(objRecent) - 2 downto 0 do
            begin
              objRecent[Ind + 1] := objRecent[Ind];

              //Log('Move2 ' + objRecent[Ind] + ' From ' + ToStr(Ind) +
              //                                ' To ' + ToStr(Ind+1));
            end;

          // Add it at index 0

          objRecent[0] := FileName;
        end;
    end;
end;
//------------------------------------------------------------------------------
// Turn Hint On or off
//------------------------------------------------------------------------------
function TMySettings.GetHintOnInt : boolean;
begin
  result := Application.ShowHint;
end;
//------------------------------------------------------------------------------
// Turn Hint On or off
//------------------------------------------------------------------------------
procedure TMySettings.SetHintOnInt(const Value : boolean);
begin
  Application.ShowHint := Value;
end;
//------------------------------------------------------------------------------
// Startup Application Settings
//------------------------------------------------------------------------------
class procedure TMySettings.AppSettingsStartup;
begin
  if (AppSettings = nil) then
    begin

{$IFDEF DEFDEBUG}
      LogToFile('');
      LogToFile(self.ClassName + resLogStartUp + CLN);
{$ENDIF}

      AppSettings := TMySettings.Create;
    end;
end;
//------------------------------------------------------------------------------
// ShutDown Application Settings
//------------------------------------------------------------------------------
class procedure TMySettings.AppSettingsShutDown;
var
  tf : TGenTextFile;
begin
  if (AppSettings <> nil) then
    begin

{$IFDEF DEFDEBUG}
      LogToFile('');
      LogToFile(self.ClassName + resLogShutDown + CLN);

        LogToFile(FixLenStrB('  TMySettings Size (b)', DebugLineWdt) +
                  IntToStr(TMySettings.InstanceSize));

        LogToFile(FixLenStrB('  Document Folder', DebugLineWdt) +
                  AppSettings.pComFolder);

        LogToFile(FixLenStrB('  Ini FileName', DebugLineWdt) +
                  ApplicationIniFile);
{$ENDIF}

        tf := TGenTextFile.Create(ApplicationIniFile);

{$IFDEF DEFDEBUG}
        LogToFile(FixLenStrB('  Ini Lines', DebugLineWdt) +
                  IntToStr(tf.pLines));
{$ENDIF}

        tf.Free;

{$IFDEF DEFDEBUG}
      LogMemToFile(resLogBefore);
{$ENDIF}

      AppSettings.free;
      AppSettings := nil;
      
{$IFDEF DEFDEBUG}
      LogMemToFile(resLogAfter);
{$ENDIF}
    end;
end;
//------------------------------------------------------------------------------
//                                    INIT
//------------------------------------------------------------------------------
initialization

  FindClass(TMySettings);

end.
