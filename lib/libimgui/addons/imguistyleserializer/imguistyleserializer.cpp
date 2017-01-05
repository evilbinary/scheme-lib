// USAGE (tested with  ImGui library v1.21 wip):
/*
1) Compile this cpp file
2) In your main.cpp just add (without including any additional file: there's no header!):
extern bool ImGuiSaveStyle(const char* filename,const ImGuiStyle& style);
extern bool ImGuiLoadStyle(const char* filename,ImGuiStyle& style);
3) Use them together with ImGui::GetStyle() to save/load the current style.
   ImGui::GetStyle() returns a reference of the current style that can be set/get.

Please note that other style options are not globally serializable because they are "window flags",
that must be set on a per-window basis (for example border,titlebar,scrollbar,resizable,movable,per-window alpha).

To edit and save a style, you can use the default ImGui example and append to the "Debug" window the following code:
            ImGui::Text("\n");
            ImGui::Text("Please modify the current style in:");
            ImGui::Text("ImGui Test->Window Options->Style Editor");
            static bool loadCurrentStyle = false;
            static bool saveCurrentStyle = false;
            static bool resetCurrentStyle = false;
            loadCurrentStyle = ImGui::Button("Load Saved Style");
            saveCurrentStyle = ImGui::Button("Save Current Style");
            resetCurrentStyle = ImGui::Button("Reset Current Style");
            if (loadCurrentStyle)   {
                if (!ImGuiLoadStyle("./myimgui.style",ImGui::GetStyle()))   {
                    fprintf(stderr,"Warning: \"./myimgui.style\" not present.\n");
                }
            }
            if (saveCurrentStyle)   {
                if (!ImGuiSaveStyle("./myimgui.style",ImGui::GetStyle()))   {
                    fprintf(stderr,"Warning: \"./myimgui.style\" cannot be saved.\n");
                }
            }
            if (resetCurrentStyle)  ImGui::GetStyle() = ImGuiStyle();
*/

#include "imguistyleserializer.h"
            
#ifndef IMGUI_API
#include <imgui.h>
#endif //IMGUI_API

// From <imgui.cpp>:--------------------------------------------------------
#ifndef IM_ARRAYSIZE
#include <stdio.h>      // vsnprintf
#define IM_ARRAYSIZE(_ARR)          ((int)(sizeof(_ARR)/sizeof(*_ARR)))
static size_t ImFormatString(char* buf, size_t buf_size, const char* fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    int w = vsnprintf(buf, buf_size, fmt, args);
    va_end(args);
    buf[buf_size-1] = 0;
    return (w == -1) ? buf_size : (size_t)w;
}
#endif //IM_ARRAYSIZE
//---------------------------------------------------------------------------

#include <string.h>

namespace ImGui	{

#ifndef NO_IMGUISTYLESERIALIZER_SAVESTYLE
bool SaveStyle(const char* filename,const ImGuiStyle& style)
{
    // Write .style file
    FILE* f = fopen(filename, "wt");
    if (!f)  return false;
 
    fprintf(f, "[Alpha]\n%1.3f\n", style.Alpha);
    fprintf(f, "[WindowPadding]\n%1.3f %1.3f\n", style.WindowPadding.x,style.WindowPadding.y);
    fprintf(f, "[WindowMinSize]\n%1.3f %1.3f\n", style.WindowMinSize.x,style.WindowMinSize.y);
    fprintf(f, "[FramePadding]\n%1.3f %1.3f\n", style.FramePadding.x,style.FramePadding.y);
    fprintf(f, "[FrameRounding]\n%1.3f\n", style.FrameRounding);
    fprintf(f, "[ItemSpacing]\n%1.3f %1.3f\n", style.ItemSpacing.x,style.ItemSpacing.y);
    fprintf(f, "[ItemInnerSpacing]\n%1.3f %1.3f\n", style.ItemInnerSpacing.x,style.ItemInnerSpacing.y);
    fprintf(f, "[TouchExtraPadding]\n%1.3f %1.3f\n", style.TouchExtraPadding.x,style.TouchExtraPadding.y);
    //fprintf(f, "[WindowFillAlphaDefault]\n%1.3f\n", style.WindowFillAlphaDefault);
    fprintf(f, "[WindowRounding]\n%1.3f\n", style.WindowRounding);
    fprintf(f, "[ScrollbarRounding]\n%1.3f\n", style.ScrollbarRounding);
    fprintf(f, "[WindowTitleAlign]\n%1.3f %1.3f\n", style.WindowTitleAlign.x,style.WindowTitleAlign.y);
    fprintf(f, "[ButtonTextAlign]\n%1.3f %1.3f\n", style.ButtonTextAlign.x,style.ButtonTextAlign.y);
    fprintf(f, "[IndentSpacing]\n%1.3f\n", style.IndentSpacing);
    fprintf(f, "[ColumnsMinSpacing]\n%1.3f\n", style.ColumnsMinSpacing);
    fprintf(f, "[ScrollbarSize]\n%1.3f\n", style.ScrollbarSize);
    fprintf(f, "[GrabMinSize]\n%1.3f\n", style.GrabMinSize);
    fprintf(f, "[GrabRounding]\n%1.3f\n", style.GrabRounding);
    fprintf(f, "[ChildWindowRounding]\n%1.3f\n", style.ChildWindowRounding);
    fprintf(f, "[DisplayWindowPadding]\n%1.3f %1.3f\n", style.DisplayWindowPadding.x,style.DisplaySafeAreaPadding.y);
    fprintf(f, "[DisplaySafeAreaPadding]\n%1.3f %1.3f\n", style.DisplaySafeAreaPadding.x,style.DisplaySafeAreaPadding.y);
    fprintf(f, "[AntiAliasedLines]\n%d\n", style.AntiAliasedLines?1:0);
    fprintf(f, "[AntiAliasedShapes]\n%d\n", style.AntiAliasedShapes?1:0);
    fprintf(f, "[CurveTessellationTol]\n%1.3f\n", style.CurveTessellationTol);

    for (size_t i = 0; i != ImGuiCol_COUNT; i++)
    {
		const ImVec4& c = style.Colors[i];
        fprintf(f, "[%s]\n", ImGui::GetStyleColName(i));//ImGuiColNames[i]);
        fprintf(f, "%1.3f %1.3f %1.3f %1.3f\n",c.x,c.y,c.z,c.w);
    }

	fprintf(f,"\n");
    fclose(f);
    
    return true;
}
#endif //NO_IMGUISTYLESERIALIZER_SAVESTYLE
#ifndef NO_IMGUISTYLESERIALIZER_LOADSTYLE
bool LoadStyle(const char* filename,ImGuiStyle& style)
{
    // Load .style file
    if (!filename)  return false;

    // Load file into memory
    FILE* f;
    if ((f = fopen(filename, "rt")) == NULL) return false;
    if (fseek(f, 0, SEEK_END))  {
       fclose(f); 
       return false; 
    }
    const long f_size_signed = ftell(f);
    if (f_size_signed == -1)    {
       fclose(f); 
       return false; 
    }
    size_t f_size = (size_t)f_size_signed;
    if (fseek(f, 0, SEEK_SET))  {
       fclose(f); 
       return false; 
    }
    char* f_data = (char*)ImGui::MemAlloc(f_size+1);
    f_size = fread(f_data, 1, f_size, f); // Text conversion alter read size so let's not be fussy about return value
    fclose(f);
    if (f_size == 0)    {
        ImGui::MemFree(f_data);
        return false;
    }
    f_data[f_size] = 0;

    float WindowFillAlphaDefault = -1.f;    // fallback for reloading an older file
    // Parse file in memory
    char name[128];name[0]='\0';
    const char* buf_end = f_data + f_size;
    for (const char* line_start = f_data; line_start < buf_end; )
    {
        const char* line_end = line_start;
        while (line_end < buf_end && *line_end != '\n' && *line_end != '\r')
            line_end++;
        
        if (name[0]=='\0' && line_start[0] == '[' && line_end > line_start && line_end[-1] == ']')
        {        
            ImFormatString(name, IM_ARRAYSIZE(name), "%.*s", (int)(line_end-line_start-2), line_start+1);
            //fprintf(stderr,"name: %s\n",name);  // dbg
        }
        else if (name[0]!='\0')
        {

            float *pf[4]= {0,0,0,0};
            int npf = 0;
            int *pi[4]={0,0,0,0};
            int npi = 0;
            bool *pb[4]= {0,0,0,0};
            int npb = 0;

            // parsing 'name' here by filling the fields above
            {
                if      (strcmp(name, "Alpha")==0)                     {npf=1;pf[0]=&style.Alpha;}
                else if (strcmp(name, "WindowPadding")==0)             {npf=2;pf[0]=&style.WindowPadding.x;pf[1]=&style.WindowPadding.y;}
                else if (strcmp(name, "WindowMinSize")==0)             {npf=2;pf[0]=&style.WindowMinSize.x;pf[1]=&style.WindowMinSize.y;}
                else if (strcmp(name, "FramePadding")==0)              {npf=2;pf[0]=&style.FramePadding.x;pf[1]=&style.FramePadding.y;}
                else if (strcmp(name, "FrameRounding")==0)             {npf=1;pf[0]=&style.FrameRounding;}
                else if (strcmp(name, "ItemSpacing")==0)               {npf=2;pf[0]=&style.ItemSpacing.x;pf[1]=&style.ItemSpacing.y;}
                else if (strcmp(name, "ItemInnerSpacing")==0)          {npf=2;pf[0]=&style.ItemInnerSpacing.x;pf[1]=&style.ItemInnerSpacing.y;}
                else if (strcmp(name, "TouchExtraPadding")==0)         {npf=2;pf[0]=&style.TouchExtraPadding.x;pf[1]=&style.TouchExtraPadding.y;}
		else if (strcmp(name, "WindowFillAlphaDefault")==0)    {npf=1;pf[0]=&WindowFillAlphaDefault;}
                else if (strcmp(name, "WindowRounding")==0)            {npf=1;pf[0]=&style.WindowRounding;}
                else if (strcmp(name, "ScrollbarRounding")==0)         {npf=1;pf[0]=&style.ScrollbarRounding;}
		else if (strcmp(name, "WindowTitleAlign")==0)          {npf=2;pf[0]=&style.WindowTitleAlign.x;pf[1]=&style.WindowTitleAlign.y;}
		else if (strcmp(name, "ButtonTextAlign")==0)          {npf=2;pf[0]=&style.ButtonTextAlign.x;pf[1]=&style.ButtonTextAlign.y;}
		else if (strcmp(name, "IndentSpacing")==0)             {npf=1;pf[0]=&style.IndentSpacing;}
                else if (strcmp(name, "ColumnsMinSpacing")==0)         {npf=1;pf[0]=&style.ColumnsMinSpacing;}
                else if (strcmp(name, "ScrollbarSize")==0)            {npf=1;pf[0]=&style.ScrollbarSize;}
                else if (strcmp(name, "GrabMinSize")==0)               {npf=1;pf[0]=&style.GrabMinSize;}
                else if (strcmp(name, "GrabRounding")==0)               {npf=1;pf[0]=&style.GrabRounding;}
                else if (strcmp(name, "ChildWindowRounding")==0)       {npf=1;pf[0]=&style.ChildWindowRounding;}
                else if (strcmp(name, "DisplayWindowPadding")==0)    {npf=2;pf[0]=&style.DisplayWindowPadding.x;pf[1]=&style.DisplayWindowPadding.y;}
                else if (strcmp(name, "DisplaySafeAreaPadding")==0)    {npf=2;pf[0]=&style.DisplaySafeAreaPadding.x;pf[1]=&style.DisplaySafeAreaPadding.y;}
                else if (strcmp(name, "AntiAliasedLines")==0)          {npb=1;pb[0]=&style.AntiAliasedLines;}
                else if (strcmp(name, "AntiAliasedShapes")==0)          {npb=1;pb[0]=&style.AntiAliasedShapes;}
                else if (strcmp(name, "CurveTessellationTol")==0)               {npf=1;pf[0]=&style.CurveTessellationTol;}


                // all the colors here
                else {
                    for (int j=0;j<ImGuiCol_COUNT;j++)    {
                        if (strcmp(name,ImGui::GetStyleColName(j))==0)    {
                            npf = 4;
                            ImVec4& color = style.Colors[j];
                            pf[0]=&color.x;pf[1]=&color.y;pf[2]=&color.z;pf[3]=&color.w;
                            break;
                        }
			// Fallback for old files -----------------------------------
			else if (strcmp(name,"TooltipBg")==0)	{
			    npf = 4;
			    ImVec4& color = style.Colors[ImGuiCol_PopupBg];
			    pf[0]=&color.x;pf[1]=&color.y;pf[2]=&color.z;pf[3]=&color.w;
			    break;
			}
			// -----------------------------------------------------------
                    }
                }
            }

            //fprintf(stderr,"name: %s npf=%d\n",name,npf);  // dbg
            // parsing values here and filling pf[]
	    float x=0.f,y=0.f,z=0.f,w=0.f;
	    int xi=0,yi=0,zi=0,wi=0;
            switch (npf)	{
            case 1:
                if (sscanf(line_start, "%f", &x) == npf)	{
                    *pf[0] = x;
                }
                else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                break;
            case 2:
                if (sscanf(line_start, "%f %f", &x, &y) == npf)	{
                    *pf[0] = x;*pf[1] = y;
                }
                else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                break;
            case 3:
                if (sscanf(line_start, "%f %f %f", &x, &y, &z) == npf)	{
                    *pf[0] = x;*pf[1] = y;*pf[2] = z;
                }
                else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                break;
            case 4:
                if (sscanf(line_start, "%f %f %f %f", &x, &y, &z, &w) == npf)	{
                    *pf[0] = x;*pf[1] = y;*pf[2] = z;*pf[3] = w;
                }
                else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                break;
            default:
                switch (npi)    {
                case 1:
                    if (sscanf(line_start, "%d", &xi) == npi)	{
                        *pi[0] = xi;
                    }
                    else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                    break;
                case 2:
                    if (sscanf(line_start, "%d %d", &xi, &yi) == npi)	{
                        *pi[0] = xi;*pi[1] = yi;
                    }
                    else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                    break;
                case 3:
                    if (sscanf(line_start, "%d %d %d", &xi, &yi, &zi) == npi)	{
                        *pi[0] = xi;*pi[1] = yi;*pi[2] = zi;
                    }
                    else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                    break;
                case 4:
                    if (sscanf(line_start, "%d %d %d %d", &xi, &yi, &zi, &wi) == npi)	{
                        *pi[0] = xi;*pi[1] = yi;*pi[2] = zi;*pi[3] = wi;
                    }
                    else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                    break;
                default:
                    switch (npb)    {
                    case 1:
                        if (sscanf(line_start, "%d", &xi) == npb)	{
                            *pb[0] = (xi!=0);
                        }
                        else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                        break;
                    case 2:
                        if (sscanf(line_start, "%d %d", &xi, &yi) == npb)	{
                            *pb[0] = (xi!=0);*pb[1] = (yi!=0);
                        }
                        else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                        break;
                    case 3:
                        if (sscanf(line_start, "%d %d %d", &xi, &yi, &zi) == npb)	{
                            *pb[0] = (xi!=0);*pb[1] = (yi!=0);*pb[2] = (zi!=0);
                        }
                        else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                        break;
                    case 4:
                        if (sscanf(line_start, "%d %d %d %d", &xi, &yi, &zi, &wi) == npb)	{
                            *pb[0] = (xi!=0);*pb[1] = (yi!=0);*pb[2] = (zi!=0);*pb[3] = (wi!=0);
                        }
                        else fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (parsing error).\n",filename,name);
                        break;
                    default:
                        fprintf(stderr,"Warning in ImGui::LoadStyle(\"%s\"): skipped [%s] (unknown field).\n",filename,name);
                        break;
                    }
                    break;
                }
                break;
            }
            /*
            // Same reference code from <imgui.cpp> to help parsing
            float x, y;
            int i;
            if (sscanf(line_start, "Pos=%f,%f", &x, &y) == 2)
                settings->Pos = ImVec2(x, y);
            else if (sscanf(line_start, "Size=%f,%f", &x, &y) == 2)
                settings->Size = ImMax(ImVec2(x, y), g.Style.WindowMinSize);
            else if (sscanf(line_start, "Collapsed=%d", &i) == 1)
                settings->Collapsed = (i != 0);
            */
	    //---------------------------------------------------------------------------------
	    // Fix backward compatibility a bit
	    if (style.WindowTitleAlign.x<0 || style.WindowTitleAlign.x>1) style.WindowTitleAlign.x = 0.f;
	    if (style.WindowTitleAlign.y<0 || style.WindowTitleAlign.y>1) style.WindowTitleAlign.y = 0.5f;
	    //---------------------------------------------------------------------------------
            name[0]='\0'; // mandatory
        }

        line_start = line_end+1;
    }

    if (WindowFillAlphaDefault>=0.f) style.Colors[ImGuiCol_WindowBg].w*=WindowFillAlphaDefault;

    // Release memory
    ImGui::MemFree(f_data);
    return true;
}
#endif //NO_IMGUISTYLESERIALIZER_LOADSTYLE


// @dougbinks (https://github.com/ocornut/imgui/issues/438)
void ChangeStyleColors(ImGuiStyle& style,float satThresholdForInvertingLuminance,float shiftHue)  {
    if (satThresholdForInvertingLuminance>=1.f && shiftHue==0.f) return;
    for (int i = 0; i < ImGuiCol_COUNT; i++)	{
	ImVec4& col = style.Colors[i];
	float H, S, V;
	ImGui::ColorConvertRGBtoHSV( col.x, col.y, col.z, H, S, V );
	if( S <= satThresholdForInvertingLuminance)  { V = 1.0 - V; }
	if (shiftHue) {H+=shiftHue;if (H>1) H-=1.f;else if (H<0) H+=1.f;}
	ImGui::ColorConvertHSVtoRGB( H, S, V, col.x, col.y, col.z );
    }
}
static inline void InvertStyleColors(ImGuiStyle& style)  {ChangeStyleColors(style,.1f,0.f);}
static inline void ChangeStyleColorsHue(ImGuiStyle& style,float shiftHue=0.f)  {ChangeStyleColors(style,0.f,shiftHue);}
static inline ImVec4 ConvertTitleBgColFromPrevVersion(const ImVec4& win_bg_col, const ImVec4& title_bg_col)	{
    float new_a = 1.0f - ((1.0f - win_bg_col.w) * (1.0f - title_bg_col.w)), k = title_bg_col.w / new_a;
    return ImVec4((win_bg_col.x * win_bg_col.w + title_bg_col.x) * k, (win_bg_col.y * win_bg_col.w + title_bg_col.y) * k, (win_bg_col.z * win_bg_col.w + title_bg_col.z) * k, new_a);
}

bool ResetStyle(int styleEnum,ImGuiStyle& style) {
    if (styleEnum<0 || styleEnum>=ImGuiStyle_Count) return false;
    style = ImGuiStyle();
    switch (styleEnum) {
    case ImGuiStyle_DefaultInverse:
	InvertStyleColors(style);
	style.Colors[ImGuiCol_PopupBg]	= ImVec4(0.79f, 0.76f, 0.725f, 0.875f);

    break;
    case ImGuiStyle_Gray:
    {
	style.AntiAliasedLines = true;
	style.AntiAliasedShapes = true;
	style.CurveTessellationTol = 1.25f;
	style.Alpha = 1.f;
	//style.WindowFillAlphaDefault = .7f;

	style.WindowPadding = ImVec2(8,8);
	style.WindowRounding = 6;
	style.ChildWindowRounding = 0;
	style.FramePadding = ImVec2(3,3);
	style.FrameRounding = 2;
	style.ItemSpacing = ImVec2(8,4);
	style.ItemInnerSpacing = ImVec2(5,5);
	style.TouchExtraPadding = ImVec2(0,0);
	style.IndentSpacing = 22;
	style.ScrollbarSize = 16;
	style.ScrollbarRounding = 4;
	style.GrabMinSize = 8;
	style.GrabRounding = 0;

	style.Colors[ImGuiCol_Text]                  = ImVec4(0.82f, 0.82f, 0.82f, 1.00f);
	style.Colors[ImGuiCol_TextDisabled]          = ImVec4(0.60f, 0.60f, 0.60f, 1.00f);
	style.Colors[ImGuiCol_WindowBg]              = ImVec4(0.16f, 0.16f, 0.18f, 0.70f);
	style.Colors[ImGuiCol_ChildWindowBg]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
	style.Colors[ImGuiCol_Border]                = ImVec4(0.00f, 0.00f, 0.00f, 0.60f);
	style.Colors[ImGuiCol_BorderShadow]          = ImVec4(0.33f, 0.29f, 0.33f, 0.60f);
	style.Colors[ImGuiCol_FrameBg]               = ImVec4(0.80f, 0.80f, 0.39f, 0.26f);
	style.Colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.90f, 0.80f, 0.80f, 0.40f);
	style.Colors[ImGuiCol_FrameBgActive]         = ImVec4(0.90f, 0.65f, 0.65f, 0.45f);
	style.Colors[ImGuiCol_TitleBg]               = ImGui::ConvertTitleBgColFromPrevVersion(style.Colors[ImGuiCol_WindowBg],ImVec4(0.26f, 0.27f, 0.74f, 1.00f));
	style.Colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(0.28f, 0.28f, 0.76f, 0.16f);
	style.Colors[ImGuiCol_TitleBgActive]         = ImGui::ConvertTitleBgColFromPrevVersion(style.Colors[ImGuiCol_WindowBg],ImVec4(0.50f, 0.50f, 1.00f, 0.55f));
	style.Colors[ImGuiCol_MenuBarBg]             = ImVec4(0.40f, 0.40f, 0.55f, 0.80f);
	style.Colors[ImGuiCol_ScrollbarBg]           = ImVec4(1.00f, 1.00f, 1.00f, 0.18f);
	style.Colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.67f, 0.58f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(0.83f, 0.88f, 0.25f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(1.00f, 1.00f, 0.67f, 1.00f);
	style.Colors[ImGuiCol_ComboBg]               = ImVec4(0.20f, 0.20f, 0.20f, 1.00f);
	style.Colors[ImGuiCol_CheckMark]             = ImVec4(0.90f, 0.90f, 0.90f, 0.50f);
	style.Colors[ImGuiCol_SliderGrab]            = ImVec4(1.00f, 1.00f, 1.00f, 0.29f);
	style.Colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.80f, 0.50f, 0.50f, 1.00f);
	style.Colors[ImGuiCol_Button]                = ImVec4(0.25f, 0.29f, 0.61f, 1.00f);
	style.Colors[ImGuiCol_ButtonHovered]         = ImVec4(0.35f, 0.40f, 0.68f, 1.00f);
	style.Colors[ImGuiCol_ButtonActive]          = ImVec4(0.50f, 0.52f, 0.81f, 1.00f);
	style.Colors[ImGuiCol_Header]                = ImVec4(0.11f, 0.37f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_HeaderHovered]         = ImVec4(0.40f, 0.50f, 0.25f, 1.00f);
	style.Colors[ImGuiCol_HeaderActive]          = ImVec4(0.51f, 0.63f, 0.27f, 1.00f);
	style.Colors[ImGuiCol_Column]                = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_ColumnHovered]         = ImVec4(0.60f, 0.40f, 0.40f, 1.00f);
	style.Colors[ImGuiCol_ColumnActive]          = ImVec4(0.80f, 0.50f, 0.50f, 1.00f);
	style.Colors[ImGuiCol_ResizeGrip]            = ImVec4(1.00f, 0.33f, 0.38f, 0.37f);
	style.Colors[ImGuiCol_ResizeGripHovered]     = ImVec4(1.00f, 0.73f, 0.69f, 0.41f);
	style.Colors[ImGuiCol_ResizeGripActive]      = ImVec4(1.00f, 1.00f, 0.75f, 0.90f);
	style.Colors[ImGuiCol_CloseButton]           = ImVec4(0.73f, 0.20f, 0.00f, 0.68f);
	style.Colors[ImGuiCol_CloseButtonHovered]    = ImVec4(1.00f, 0.27f, 0.27f, 0.50f);
	style.Colors[ImGuiCol_CloseButtonActive]     = ImVec4(0.38f, 0.23f, 0.12f, 0.50f);
	style.Colors[ImGuiCol_PlotLines]             = ImVec4(0.73f, 0.68f, 0.65f, 1.00f);
	style.Colors[ImGuiCol_PlotLinesHovered]      = ImVec4(0.90f, 0.70f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogram]         = ImVec4(0.90f, 0.70f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(1.00f, 0.60f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextSelectedBg]        = ImVec4(0.00f, 0.00f, 0.66f, 0.34f);
	style.Colors[ImGuiCol_PopupBg]               = ImVec4(0.05f, 0.05f, 0.10f, 0.90f);
	style.Colors[ImGuiCol_ModalWindowDarkening]  = ImVec4(0.20f, 0.20f, 0.20f, 0.35f);	
    }
    break;
    case ImGuiStyle_Light:
    {
	style.AntiAliasedLines = true;
	style.AntiAliasedShapes = true;
	style.CurveTessellationTol = 1.25f;
	style.Alpha = 1.f;
	//style.WindowFillAlphaDefault = .7f;

	style.WindowPadding = ImVec2(8,8);
	style.WindowRounding = 6;
	style.ChildWindowRounding = 0;
	style.FramePadding = ImVec2(4,3);
	style.FrameRounding = 0;
	style.ItemSpacing = ImVec2(8,4);
	style.ItemInnerSpacing = ImVec2(4,4);
	style.TouchExtraPadding = ImVec2(0,0);
	style.IndentSpacing = 21;
	style.ScrollbarSize = 16;
	style.ScrollbarRounding = 4;
	style.GrabMinSize = 8;
	style.GrabRounding = 0;

	style.Colors[ImGuiCol_Text]                  = ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextDisabled]          = ImVec4(0.00f, 0.00f, 0.00f, 0.71f);
	style.Colors[ImGuiCol_WindowBg]              = ImVec4(0.56f, 0.56f, 0.56f, 1.00f);
	style.Colors[ImGuiCol_ChildWindowBg]         = ImVec4(0.99f, 1.00f, 0.71f, 0.10f);
	style.Colors[ImGuiCol_PopupBg]               = ImVec4(0.51f, 0.63f, 0.63f, 0.92f);
	style.Colors[ImGuiCol_Border]                = ImVec4(0.14f, 0.14f, 0.14f, 0.51f);
	style.Colors[ImGuiCol_BorderShadow]          = ImVec4(0.86f, 0.86f, 0.86f, 0.51f);
	style.Colors[ImGuiCol_FrameBg]               = ImVec4(0.54f, 0.67f, 0.67f, 1.00f);
	style.Colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.61f, 0.74f, 0.75f, 1.00f);
	style.Colors[ImGuiCol_FrameBgActive]         = ImVec4(0.67f, 0.82f, 0.82f, 1.00f);
	style.Colors[ImGuiCol_TitleBg]               = ImVec4(0.54f, 0.54f, 0.24f, 1.00f);
	style.Colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(0.54f, 0.54f, 0.24f, 0.39f);
	style.Colors[ImGuiCol_TitleBgActive]         = ImVec4(0.68f, 0.69f, 0.30f, 1.00f);
	style.Colors[ImGuiCol_MenuBarBg]             = ImVec4(0.50f, 0.57f, 0.73f, 0.92f);
	style.Colors[ImGuiCol_ScrollbarBg]           = ImVec4(0.26f, 0.29f, 0.31f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.61f, 0.60f, 0.26f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(0.73f, 0.72f, 0.31f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(0.82f, 0.82f, 0.35f, 1.00f);
	style.Colors[ImGuiCol_ComboBg]               = ImVec4(0.51f, 0.63f, 0.63f, 0.92f);
	style.Colors[ImGuiCol_CheckMark]             = ImVec4(0.85f, 0.86f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_SliderGrab]            = ImVec4(0.81f, 0.82f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.87f, 0.88f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_Button]                = ImVec4(0.41f, 0.59f, 0.31f, 1.00f);
	style.Colors[ImGuiCol_ButtonHovered]         = ImVec4(0.45f, 0.65f, 0.34f, 1.00f);
	style.Colors[ImGuiCol_ButtonActive]          = ImVec4(0.50f, 0.73f, 0.38f, 1.00f);
	style.Colors[ImGuiCol_Header]                = ImVec4(0.42f, 0.47f, 0.88f, 1.00f);
	style.Colors[ImGuiCol_HeaderHovered]         = ImVec4(0.44f, 0.51f, 0.93f, 1.00f);
	style.Colors[ImGuiCol_HeaderActive]          = ImVec4(0.50f, 0.62f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_Column]                = ImVec4(0.13f, 0.14f, 0.11f, 1.00f);
	style.Colors[ImGuiCol_ColumnHovered]         = ImVec4(0.73f, 0.75f, 0.61f, 1.00f);
	style.Colors[ImGuiCol_ColumnActive]          = ImVec4(0.89f, 0.90f, 0.70f, 1.00f);
	style.Colors[ImGuiCol_ResizeGrip]            = ImVec4(0.61f, 0.22f, 0.22f, 1.00f);
	style.Colors[ImGuiCol_ResizeGripHovered]     = ImVec4(0.69f, 0.24f, 0.24f, 1.00f);
	style.Colors[ImGuiCol_ResizeGripActive]      = ImVec4(0.80f, 0.28f, 0.28f, 1.00f);
	style.Colors[ImGuiCol_CloseButton]           = ImVec4(0.67f, 0.00f, 0.00f, 0.50f);
	style.Colors[ImGuiCol_CloseButtonHovered]    = ImVec4(0.78f, 0.00f, 0.00f, 0.60f);
	style.Colors[ImGuiCol_CloseButtonActive]     = ImVec4(0.92f, 0.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_PlotLines]             = ImVec4(0.17f, 0.35f, 0.03f, 1.00f);
	style.Colors[ImGuiCol_PlotLinesHovered]      = ImVec4(0.41f, 0.81f, 0.06f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogram]         = ImVec4(0.81f, 0.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextSelectedBg]        = ImVec4(0.48f, 0.61f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_ModalWindowDarkening]  = ImVec4(0.39f, 0.12f, 0.12f, 0.20f);
    }
    break;
    case ImGuiStyle_OSX:
    case ImGuiStyle_OSXInverse:    {
	// Posted by @itamago here: https://github.com/ocornut/imgui/pull/511
	style.Colors[ImGuiCol_Text]                  = ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextDisabled]          = ImVec4(0.60f, 0.60f, 0.60f, 1.00f);
	//style.Colors[ImGuiCol_TextHovered]           = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	//style.Colors[ImGuiCol_TextActive]            = ImVec4(1.00f, 1.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_WindowBg]              = ImVec4(0.94f, 0.94f, 0.94f, 0.7f);
	style.Colors[ImGuiCol_ChildWindowBg]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
	style.Colors[ImGuiCol_Border]                = ImVec4(0.00f, 0.00f, 0.00f, 0.39f);
	style.Colors[ImGuiCol_BorderShadow]          = ImVec4(1.00f, 1.00f, 1.00f, 0.10f);
	style.Colors[ImGuiCol_FrameBg]               = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.26f, 0.59f, 0.98f, 0.40f);
	style.Colors[ImGuiCol_FrameBgActive]         = ImVec4(0.26f, 0.59f, 0.98f, 0.67f);
	style.Colors[ImGuiCol_TitleBg]               = ImVec4(0.96f, 0.96f, 0.96f, 1.00f);
	style.Colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(1.00f, 1.00f, 1.00f, 0.51f);
	style.Colors[ImGuiCol_TitleBgActive]         = ImVec4(0.82f, 0.82f, 0.82f, 1.00f);
	style.Colors[ImGuiCol_MenuBarBg]             = ImVec4(0.86f, 0.86f, 0.86f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarBg]           = ImVec4(0.98f, 0.98f, 0.98f, 0.53f);
	style.Colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.69f, 0.69f, 0.69f, 0.80f);
	style.Colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(0.49f, 0.49f, 0.49f, 0.80f);
	style.Colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(0.49f, 0.49f, 0.49f, 1.00f);
	style.Colors[ImGuiCol_ComboBg]               = ImVec4(0.86f, 0.86f, 0.86f, 0.99f);
	style.Colors[ImGuiCol_CheckMark]             = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_SliderGrab]            = ImVec4(0.26f, 0.59f, 0.98f, 0.78f);
	style.Colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_Button]                = ImVec4(0.26f, 0.59f, 0.98f, 0.40f);
	style.Colors[ImGuiCol_ButtonHovered]         = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_ButtonActive]          = ImVec4(0.06f, 0.53f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_Header]                = ImVec4(0.26f, 0.59f, 0.98f, 0.31f);
	style.Colors[ImGuiCol_HeaderHovered]         = ImVec4(0.26f, 0.59f, 0.98f, 0.80f);
	style.Colors[ImGuiCol_HeaderActive]          = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_Column]                = ImVec4(0.39f, 0.39f, 0.39f, 1.00f);
	style.Colors[ImGuiCol_ColumnHovered]         = ImVec4(0.26f, 0.59f, 0.98f, 0.78f);
	style.Colors[ImGuiCol_ColumnActive]          = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_ResizeGrip]            = ImVec4(1.00f, 1.00f, 1.00f, 0.00f);
	style.Colors[ImGuiCol_ResizeGripHovered]     = ImVec4(0.26f, 0.59f, 0.98f, 0.67f);
	style.Colors[ImGuiCol_ResizeGripActive]      = ImVec4(0.26f, 0.59f, 0.98f, 0.95f);
	style.Colors[ImGuiCol_CloseButton]           = ImVec4(0.59f, 0.59f, 0.59f, 0.50f);
	style.Colors[ImGuiCol_CloseButtonHovered]    = ImVec4(0.98f, 0.39f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_CloseButtonActive]     = ImVec4(0.98f, 0.39f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_PlotLines]             = ImVec4(0.39f, 0.39f, 0.39f, 1.00f);
	style.Colors[ImGuiCol_PlotLinesHovered]      = ImVec4(1.00f, 0.43f, 0.35f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogram]         = ImVec4(0.90f, 0.70f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(1.00f, 0.60f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextSelectedBg]        = ImVec4(0.26f, 0.59f, 0.98f, 0.35f);
	style.Colors[ImGuiCol_PopupBg]		     = ImVec4(1.00f, 1.00f, 1.00f, 0.94f);
	style.Colors[ImGuiCol_ModalWindowDarkening]  = ImVec4(0.20f, 0.20f, 0.20f, 0.35f);

	if (styleEnum == ImGuiStyle_OSXInverse) InvertStyleColors(style);
    }
    break;
    case ImGuiStyle_DarkOpaque:
    case ImGuiStyle_DarkOpaqueInverse:	    {
	style.AntiAliasedLines = true;
	style.AntiAliasedShapes = true;
	style.CurveTessellationTol = 1.25f;
	style.Alpha = 1.f;
	//style.WindowFillAlphaDefault = .7f;

	style.WindowPadding = ImVec2(8,8);
	style.WindowRounding = 4;
	style.ChildWindowRounding = 0;
	style.FramePadding = ImVec2(3,3);
	style.FrameRounding = 0;
	style.ItemSpacing = ImVec2(8,4);
	style.ItemInnerSpacing = ImVec2(5,5);
	style.TouchExtraPadding = ImVec2(0,0);
	style.IndentSpacing = 22;
	style.ScrollbarSize = 16;
	style.ScrollbarRounding = 8;
	style.GrabMinSize = 8;
	style.GrabRounding = 0;

	ImGuiStyle& style = ImGui::GetStyle();
	style.Colors[ImGuiCol_Text]                  = ImVec4(0.73f, 0.73f, 0.73f, 1.00f);
	style.Colors[ImGuiCol_TextDisabled]          = ImVec4(0.73f, 0.73f, 0.73f, 0.39f);
	style.Colors[ImGuiCol_WindowBg]              = ImVec4(0.18f, 0.18f, 0.18f, 1.00f);
	style.Colors[ImGuiCol_ChildWindowBg]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
	style.Colors[ImGuiCol_PopupBg]               = ImVec4(0.01f, 0.04f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_Border]                = ImVec4(0.04f, 0.04f, 0.04f, 0.51f);
	style.Colors[ImGuiCol_BorderShadow]          = ImVec4(0.18f, 0.18f, 0.18f, 1.00f);
	style.Colors[ImGuiCol_FrameBg]               = ImVec4(0.33f, 0.33f, 0.33f, 1.00f);
	style.Colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.39f, 0.39f, 0.40f, 1.00f);
	style.Colors[ImGuiCol_FrameBgActive]         = ImVec4(0.54f, 0.54f, 0.55f, 1.00f);
	style.Colors[ImGuiCol_TitleBg]               = ImVec4(0.25f, 0.25f, 0.24f, 1.00f);
	style.Colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(0.25f, 0.25f, 0.24f, 0.23f);
	style.Colors[ImGuiCol_TitleBgActive]         = ImVec4(0.35f, 0.35f, 0.34f, 1.00f);
	style.Colors[ImGuiCol_MenuBarBg]             = ImVec4(0.38f, 0.38f, 0.45f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarBg]           = ImVec4(0.24f, 0.27f, 0.30f, 0.60f);
	style.Colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.64f, 0.64f, 0.80f, 0.59f);
	style.Colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(0.64f, 0.64f, 0.80f, 0.78f);
	style.Colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(0.64f, 0.64f, 0.80f, 1.00f);
	style.Colors[ImGuiCol_ComboBg]               = ImVec4(0.10f, 0.10f, 0.10f, 1.00f);
	style.Colors[ImGuiCol_CheckMark]             = ImVec4(0.69f, 0.69f, 0.69f, 1.00f);
	style.Colors[ImGuiCol_SliderGrab]            = ImVec4(0.69f, 0.69f, 0.69f, 1.00f);
	style.Colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.88f, 0.88f, 0.88f, 1.00f);
	style.Colors[ImGuiCol_Button]                = ImVec4(0.25f, 0.25f, 0.25f, 1.00f);
	style.Colors[ImGuiCol_ButtonHovered]         = ImVec4(0.33f, 0.33f, 0.33f, 1.00f);
	style.Colors[ImGuiCol_ButtonActive]          = ImVec4(0.45f, 0.45f, 0.45f, 1.00f);
	style.Colors[ImGuiCol_Header]                = ImVec4(0.25f, 0.25f, 0.25f, 1.00f);
	style.Colors[ImGuiCol_HeaderHovered]         = ImVec4(0.35f, 0.35f, 0.35f, 1.00f);
	style.Colors[ImGuiCol_HeaderActive]          = ImVec4(0.42f, 0.42f, 0.43f, 1.00f);
	style.Colors[ImGuiCol_Column]                = ImVec4(0.84f, 0.84f, 0.84f, 0.90f);
	style.Colors[ImGuiCol_ColumnHovered]         = ImVec4(0.90f, 0.90f, 0.90f, 0.95f);
	style.Colors[ImGuiCol_ColumnActive]          = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_ResizeGrip]            = ImVec4(1.00f, 1.00f, 1.00f, 0.30f);
	style.Colors[ImGuiCol_ResizeGripHovered]     = ImVec4(1.00f, 1.00f, 1.00f, 0.60f);
	style.Colors[ImGuiCol_ResizeGripActive]      = ImVec4(1.00f, 1.00f, 1.00f, 0.90f);
	style.Colors[ImGuiCol_CloseButton]           = ImVec4(0.70f, 0.72f, 0.71f, 1.00f);
	style.Colors[ImGuiCol_CloseButtonHovered]    = ImVec4(0.83f, 0.86f, 0.84f, 1.00f);
	style.Colors[ImGuiCol_CloseButtonActive]     = ImVec4(0.70f, 0.70f, 0.70f, 1.00f);
	style.Colors[ImGuiCol_PlotLines]             = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_PlotLinesHovered]      = ImVec4(0.90f, 0.78f, 0.37f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogram]         = ImVec4(0.90f, 0.78f, 0.37f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(1.00f, 0.77f, 0.41f, 1.00f);
	style.Colors[ImGuiCol_TextSelectedBg]        = ImVec4(0.26f, 0.26f, 0.63f, 1.00f);
	style.Colors[ImGuiCol_ModalWindowDarkening]  = ImVec4(0.20f, 0.20f, 0.20f, 0.35f);

	if (styleEnum == ImGuiStyle_DarkOpaqueInverse) {
	    InvertStyleColors(style);
	    style.Colors[ImGuiCol_PopupBg]	     = ImVec4(0.99f, 0.96f, 1.00f, 1.00f);
	}
    }
    break;
    case ImGuiStyle_OSXOpaque:
    case ImGuiStyle_OSXOpaqueInverse:	    {
	//ImVec4 Full = ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
	style.FrameRounding = 3.0f;
	style.Colors[ImGuiCol_Text]                  = ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextDisabled]          = ImVec4(0.60f, 0.60f, 0.60f, 1.00f);
	style.Colors[ImGuiCol_WindowBg]              = ImVec4(0.94f, 0.94f, 0.94f, 1.00f);
	style.Colors[ImGuiCol_ChildWindowBg]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
	style.Colors[ImGuiCol_Border]                = ImVec4(0.00f, 0.00f, 0.00f, 0.39f);
	style.Colors[ImGuiCol_BorderShadow]          = ImVec4(1.00f, 1.00f, 1.00f, 0.10f);
	style.Colors[ImGuiCol_FrameBg]               = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.26f, 0.59f, 0.98f, 0.40f);
	style.Colors[ImGuiCol_FrameBgActive]         = ImVec4(0.26f, 0.59f, 0.98f, 0.67f);
	style.Colors[ImGuiCol_TitleBg]               = ImVec4(0.96f, 0.96f, 0.96f, 1.00f);
	style.Colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(1.00f, 1.00f, 1.00f, 0.51f);
	style.Colors[ImGuiCol_TitleBgActive]         = ImVec4(0.82f, 0.82f, 0.82f, 1.00f);
	style.Colors[ImGuiCol_MenuBarBg]             = ImVec4(0.86f, 0.86f, 0.86f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarBg]           = ImVec4(0.98f, 0.98f, 0.98f, 0.53f);
	style.Colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.69f, 0.69f, 0.69f, 0.80f);
	style.Colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(0.49f, 0.49f, 0.49f, 0.80f);
	style.Colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(0.49f, 0.49f, 0.49f, 1.00f);
	style.Colors[ImGuiCol_ComboBg]               = ImVec4(0.86f, 0.86f, 0.86f, 0.99f);
	style.Colors[ImGuiCol_CheckMark]             = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_SliderGrab]            = ImVec4(0.26f, 0.59f, 0.98f, 0.78f);
	style.Colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_Button]                = ImVec4(0.26f, 0.59f, 0.98f, 0.40f);
	style.Colors[ImGuiCol_ButtonHovered]         = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_ButtonActive]          = ImVec4(0.06f, 0.53f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_Header]                = ImVec4(0.26f, 0.59f, 0.98f, 0.31f);
	style.Colors[ImGuiCol_HeaderHovered]         = ImVec4(0.26f, 0.59f, 0.98f, 0.80f);
	style.Colors[ImGuiCol_HeaderActive]          = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_Column]                = ImVec4(0.39f, 0.39f, 0.39f, 1.00f);
	style.Colors[ImGuiCol_ColumnHovered]         = ImVec4(0.26f, 0.59f, 0.98f, 0.78f);
	style.Colors[ImGuiCol_ColumnActive]          = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_ResizeGrip]            = ImVec4(1.00f, 1.00f, 1.00f, 0.50f);
	style.Colors[ImGuiCol_ResizeGripHovered]     = ImVec4(0.26f, 0.59f, 0.98f, 0.67f);
	style.Colors[ImGuiCol_ResizeGripActive]      = ImVec4(0.26f, 0.59f, 0.98f, 0.95f);
	style.Colors[ImGuiCol_CloseButton]           = ImVec4(0.59f, 0.59f, 0.59f, 0.50f);
	style.Colors[ImGuiCol_CloseButtonHovered]    = ImVec4(0.98f, 0.39f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_CloseButtonActive]     = ImVec4(0.98f, 0.39f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_PlotLines]             = ImVec4(0.39f, 0.39f, 0.39f, 1.00f);
	style.Colors[ImGuiCol_PlotLinesHovered]      = ImVec4(1.00f, 0.43f, 0.35f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogram]         = ImVec4(0.90f, 0.70f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(1.00f, 0.60f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextSelectedBg]        = ImVec4(0.26f, 0.59f, 0.98f, 0.35f);
	style.Colors[ImGuiCol_PopupBg]		     = ImVec4(1.00f, 1.00f, 1.00f, 0.94f);
	style.Colors[ImGuiCol_ModalWindowDarkening]  = ImVec4(0.20f, 0.20f, 0.20f, 0.35f);

	if (styleEnum == ImGuiStyle_OSXOpaqueInverse) {
	    InvertStyleColors(style);
	    //style.Colors[ImGuiCol_PopupBg]	     = ImVec4(0.3f, 0.3f, 0.4f, 1.00f);
	}

    }
    break;
    case ImGuiStyle_Soft:   {
	// style by olekristensen [https://github.com/ocornut/imgui/issues/539]
	/* olekristensen used it wth these fonts:
	io.Fonts->Clear();
    io.Fonts->AddFontFromFileTTF(ofToDataPath("fonts/OpenSans-Light.ttf", true).c_str(), 16);
    io.Fonts->AddFontFromFileTTF(ofToDataPath("fonts/OpenSans-Regular.ttf", true).c_str(), 16);
    io.Fonts->AddFontFromFileTTF(ofToDataPath("fonts/OpenSans-Light.ttf", true).c_str(), 32);
    io.Fonts->AddFontFromFileTTF(ofToDataPath("fonts/OpenSans-Regular.ttf", true).c_str(), 11);
    io.Fonts->AddFontFromFileTTF(ofToDataPath("fonts/OpenSans-Bold.ttf", true).c_str(), 11);
    io.Fonts->Build();*/

	style.WindowPadding            = ImVec2(15, 15);
	style.WindowRounding           = 5.0f;
	style.FramePadding             = ImVec2(5, 5);
	style.FrameRounding            = 4.0f;
	style.ItemSpacing              = ImVec2(12, 8);
	style.ItemInnerSpacing         = ImVec2(8, 6);
	style.IndentSpacing            = 25.0f;
	style.ScrollbarSize            = 15.0f;
	style.ScrollbarRounding        = 9.0f;
	style.GrabMinSize              = 5.0f;
	style.GrabRounding             = 3.0f;

	style.Colors[ImGuiCol_Text]                  = ImVec4(0.40f, 0.39f, 0.38f, 1.00f);
	style.Colors[ImGuiCol_TextDisabled]          = ImVec4(0.40f, 0.39f, 0.38f, 0.77f);
	style.Colors[ImGuiCol_WindowBg]              = ImVec4(0.92f, 0.91f, 0.88f, 0.70f);
	style.Colors[ImGuiCol_ChildWindowBg]         = ImVec4(1.00f, 0.98f, 0.95f, 0.58f);
	style.Colors[ImGuiCol_PopupBg]               = ImVec4(0.92f, 0.91f, 0.88f, 0.92f);
	style.Colors[ImGuiCol_Border]                = ImVec4(0.84f, 0.83f, 0.80f, 0.65f);
	style.Colors[ImGuiCol_BorderShadow]          = ImVec4(0.92f, 0.91f, 0.88f, 0.00f);
	style.Colors[ImGuiCol_FrameBg]               = ImVec4(1.00f, 0.98f, 0.95f, 1.00f);
	style.Colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.99f, 1.00f, 0.40f, 0.78f);
	style.Colors[ImGuiCol_FrameBgActive]         = ImVec4(0.26f, 1.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TitleBg]               = ImVec4(1.00f, 0.98f, 0.95f, 1.00f);
	style.Colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(1.00f, 0.98f, 0.95f, 0.75f);
	style.Colors[ImGuiCol_TitleBgActive]         = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_MenuBarBg]             = ImVec4(1.00f, 0.98f, 0.95f, 0.47f);
	style.Colors[ImGuiCol_ScrollbarBg]           = ImVec4(1.00f, 0.98f, 0.95f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.00f, 0.00f, 0.00f, 0.21f);
	style.Colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(0.90f, 0.91f, 0.00f, 0.78f);
	style.Colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_ComboBg]               = ImVec4(1.00f, 0.98f, 0.95f, 1.00f);
	style.Colors[ImGuiCol_CheckMark]             = ImVec4(0.25f, 1.00f, 0.00f, 0.80f);
	style.Colors[ImGuiCol_SliderGrab]            = ImVec4(0.00f, 0.00f, 0.00f, 0.14f);
	style.Colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_Button]                = ImVec4(0.00f, 0.00f, 0.00f, 0.14f);
	style.Colors[ImGuiCol_ButtonHovered]         = ImVec4(0.99f, 1.00f, 0.22f, 0.86f);
	style.Colors[ImGuiCol_ButtonActive]          = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_Header]                = ImVec4(0.25f, 1.00f, 0.00f, 0.76f);
	style.Colors[ImGuiCol_HeaderHovered]         = ImVec4(0.25f, 1.00f, 0.00f, 0.86f);
	style.Colors[ImGuiCol_HeaderActive]          = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_Column]                = ImVec4(0.00f, 0.00f, 0.00f, 0.32f);
	style.Colors[ImGuiCol_ColumnHovered]         = ImVec4(0.25f, 1.00f, 0.00f, 0.78f);
	style.Colors[ImGuiCol_ColumnActive]          = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_ResizeGrip]            = ImVec4(0.00f, 0.00f, 0.00f, 0.04f);
	style.Colors[ImGuiCol_ResizeGripHovered]     = ImVec4(0.25f, 1.00f, 0.00f, 0.78f);
	style.Colors[ImGuiCol_ResizeGripActive]      = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_CloseButton]           = ImVec4(0.40f, 0.39f, 0.38f, 0.16f);
	style.Colors[ImGuiCol_CloseButtonHovered]    = ImVec4(0.40f, 0.39f, 0.38f, 0.39f);
	style.Colors[ImGuiCol_CloseButtonActive]     = ImVec4(0.40f, 0.39f, 0.38f, 1.00f);
	style.Colors[ImGuiCol_PlotLines]             = ImVec4(0.40f, 0.39f, 0.38f, 0.63f);
	style.Colors[ImGuiCol_PlotLinesHovered]      = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogram]         = ImVec4(0.40f, 0.39f, 0.38f, 0.63f);
	style.Colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextSelectedBg]        = ImVec4(0.25f, 1.00f, 0.00f, 0.43f);
	style.Colors[ImGuiCol_ModalWindowDarkening]  = ImVec4(1.00f, 0.98f, 0.95f, 0.73f);
    }
    break;
    case ImGuiStyle_EdinBlack: {
	// style based on an image posted by edin_p in the screenshot section (part 3) of Dear ImGui Issue Section.
	style.WindowRounding = 6.f;
	style.ScrollbarRounding = 2.f;
	style.WindowTitleAlign.x=0.45f;
	style.Colors[ImGuiCol_Text]                  = ImVec4(0.98f, 0.98f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_TextDisabled]          = ImVec4(0.98f, 0.98f, 0.98f, 0.50f);
	style.Colors[ImGuiCol_WindowBg]              = ImVec4(0.10f, 0.10f, 0.10f, 1.00f);
	style.Colors[ImGuiCol_ChildWindowBg]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
	style.Colors[ImGuiCol_PopupBg]               = ImVec4(0.10f, 0.10f, 0.10f, 0.90f);
	style.Colors[ImGuiCol_Border]                = ImVec4(0.27f, 0.27f, 0.27f, 1.00f);
	style.Colors[ImGuiCol_BorderShadow]          = ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_FrameBg]               = ImVec4(0.23f, 0.23f, 0.23f, 1.00f);
	style.Colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.28f, 0.28f, 0.28f, 0.40f);
	style.Colors[ImGuiCol_FrameBgActive]         = ImVec4(0.31f, 0.31f, 0.31f, 0.45f);
	style.Colors[ImGuiCol_TitleBg]               = ImVec4(0.19f, 0.19f, 0.19f, 1.00f);
	style.Colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(0.19f, 0.19f, 0.19f, 0.20f);
	style.Colors[ImGuiCol_TitleBgActive]         = ImVec4(0.30f, 0.30f, 0.30f, 0.87f);
	style.Colors[ImGuiCol_MenuBarBg]             = ImVec4(0.10f, 0.10f, 0.10f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarBg]           = ImVec4(0.30f, 0.30f, 0.30f, 0.60f);
	style.Colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.80f, 0.80f, 0.80f, 0.30f);
	style.Colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(0.80f, 0.80f, 0.80f, 0.40f);
	style.Colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(0.86f, 0.86f, 0.86f, 0.52f);
	style.Colors[ImGuiCol_ComboBg]               = ImVec4(0.21f, 0.21f, 0.21f, 0.99f);
	style.Colors[ImGuiCol_CheckMark]             = ImVec4(0.47f, 0.47f, 0.47f, 1.00f);
	style.Colors[ImGuiCol_SliderGrab]            = ImVec4(0.60f, 0.60f, 0.60f, 0.34f);
	style.Colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.84f, 0.84f, 0.84f, 0.34f);
	style.Colors[ImGuiCol_Button]                = ImVec4(0.29f, 0.29f, 0.29f, 1.00f);
	style.Colors[ImGuiCol_ButtonHovered]         = ImVec4(0.33f, 0.33f, 0.33f, 1.00f);
	style.Colors[ImGuiCol_ButtonActive]          = ImVec4(0.42f, 0.42f, 0.42f, 1.00f);
	style.Colors[ImGuiCol_Header]                = ImVec4(0.34f, 0.34f, 0.34f, 1.00f);
	style.Colors[ImGuiCol_HeaderHovered]         = ImVec4(0.42f, 0.42f, 0.42f, 1.00f);
	style.Colors[ImGuiCol_HeaderActive]          = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
	style.Colors[ImGuiCol_Column]                = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
	style.Colors[ImGuiCol_ColumnHovered]         = ImVec4(0.70f, 0.60f, 0.60f, 1.00f);
	style.Colors[ImGuiCol_ColumnActive]          = ImVec4(0.90f, 0.70f, 0.70f, 1.00f);
	style.Colors[ImGuiCol_ResizeGrip]            = ImVec4(1.00f, 1.00f, 1.00f, 0.30f);
	style.Colors[ImGuiCol_ResizeGripHovered]     = ImVec4(1.00f, 1.00f, 1.00f, 0.60f);
	style.Colors[ImGuiCol_ResizeGripActive]      = ImVec4(1.00f, 1.00f, 1.00f, 0.90f);
	style.Colors[ImGuiCol_CloseButton]           = ImVec4(1.00f, 1.00f, 1.00f, 0.50f);
	style.Colors[ImGuiCol_CloseButtonHovered]    = ImVec4(0.90f, 0.90f, 0.90f, 0.60f);
	style.Colors[ImGuiCol_CloseButtonActive]     = ImVec4(0.70f, 0.70f, 0.70f, 1.00f);
	style.Colors[ImGuiCol_PlotLines]             = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_PlotLinesHovered]      = ImVec4(0.90f, 0.70f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogram]         = ImVec4(0.90f, 0.70f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(1.00f, 0.60f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextSelectedBg]        = ImVec4(0.27f, 0.36f, 0.59f, 0.61f);
	style.Colors[ImGuiCol_ModalWindowDarkening]  = ImVec4(0.20f, 0.20f, 0.20f, 0.35f);


    }
    break;
    case ImGuiStyle_EdinWhite: {
	// style based on an image posted by edin_p in the screenshot section (part 3) of Dear ImGui Issue Section.
	style.WindowRounding = 6.f;
	style.ScrollbarRounding = 2.f;
	style.WindowTitleAlign.x=0.45f;
	style.Colors[ImGuiCol_Text]                  = ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextDisabled]          = ImVec4(0.00f, 0.00f, 0.00f, 0.50f);
	style.Colors[ImGuiCol_WindowBg]              = ImVec4(0.92f, 0.92f, 0.92f, 1.00f);
	style.Colors[ImGuiCol_ChildWindowBg]         = ImVec4(1.00f, 1.00f, 1.00f, 0.00f);
	style.Colors[ImGuiCol_PopupBg]               = ImVec4(1.00f, 1.00f, 1.00f, 0.92f);
	style.Colors[ImGuiCol_Border]                = ImVec4(0.73f, 0.73f, 0.73f, 0.65f);
	style.Colors[ImGuiCol_BorderShadow]          = ImVec4(0.65f, 0.65f, 0.65f, 0.31f);
	style.Colors[ImGuiCol_FrameBg]               = ImVec4(0.96f, 0.96f, 0.96f, 1.00f);
	style.Colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.98f, 0.98f, 0.98f, 0.88f);
	style.Colors[ImGuiCol_FrameBgActive]         = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_TitleBg]               = ImVec4(0.94f, 0.94f, 0.94f, 1.00f);
	style.Colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(0.94f, 0.94f, 0.94f, 0.20f);
	style.Colors[ImGuiCol_TitleBgActive]         = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_MenuBarBg]             = ImVec4(0.95f, 0.95f, 0.95f, 0.92f);
	style.Colors[ImGuiCol_ScrollbarBg]           = ImVec4(0.96f, 0.96f, 0.96f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.75f, 0.75f, 0.75f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(0.67f, 0.67f, 0.67f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(0.55f, 0.55f, 0.55f, 1.00f);
	style.Colors[ImGuiCol_ComboBg]               = ImVec4(0.96f, 0.96f, 0.96f, 0.92f);
	style.Colors[ImGuiCol_CheckMark]             = ImVec4(0.72f, 0.72f, 0.72f, 1.00f);
	style.Colors[ImGuiCol_SliderGrab]            = ImVec4(0.57f, 0.57f, 0.57f, 0.34f);
	style.Colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.24f, 0.24f, 0.24f, 0.34f);
	style.Colors[ImGuiCol_Button]                = ImVec4(0.97f, 0.97f, 0.97f, 1.00f);
	style.Colors[ImGuiCol_ButtonHovered]         = ImVec4(0.93f, 0.93f, 0.93f, 1.00f);
	style.Colors[ImGuiCol_ButtonActive]          = ImVec4(0.84f, 0.84f, 0.84f, 1.00f);
	style.Colors[ImGuiCol_Header]                = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_HeaderHovered]         = ImVec4(0.92f, 0.92f, 0.92f, 1.00f);
	style.Colors[ImGuiCol_HeaderActive]          = ImVec4(0.84f, 0.84f, 0.84f, 1.00f);
	style.Colors[ImGuiCol_Column]                = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
	style.Colors[ImGuiCol_ColumnHovered]         = ImVec4(0.70f, 0.60f, 0.60f, 1.00f);
	style.Colors[ImGuiCol_ColumnActive]          = ImVec4(0.90f, 0.70f, 0.70f, 1.00f);
	style.Colors[ImGuiCol_ResizeGrip]            = ImVec4(0.00f, 0.00f, 0.00f, 0.30f);
	style.Colors[ImGuiCol_ResizeGripHovered]     = ImVec4(0.00f, 0.00f, 0.00f, 0.37f);
	style.Colors[ImGuiCol_ResizeGripActive]      = ImVec4(0.00f, 0.00f, 0.00f, 0.47f);
	style.Colors[ImGuiCol_CloseButton]           = ImVec4(0.00f, 0.00f, 0.00f, 0.18f);
	style.Colors[ImGuiCol_CloseButtonHovered]    = ImVec4(0.10f, 0.10f, 0.10f, 0.12f);
	style.Colors[ImGuiCol_CloseButtonActive]     = ImVec4(0.30f, 0.30f, 0.30f, 0.08f);
	style.Colors[ImGuiCol_PlotLines]             = ImVec4(0.41f, 0.41f, 0.41f, 1.00f);
	style.Colors[ImGuiCol_PlotLinesHovered]      = ImVec4(0.69f, 0.56f, 0.12f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogram]         = ImVec4(0.64f, 0.50f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(0.37f, 0.22f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextSelectedBg]        = ImVec4(0.46f, 0.61f, 1.00f, 0.61f);
	style.Colors[ImGuiCol_ModalWindowDarkening]  = ImVec4(0.80f, 0.80f, 0.80f, 0.35f);

    }
    break;
    case ImGuiStyle_Maya: {
	// Posted by @ongamex here https://gist.github.com/ongamex/4ee36fb23d6c527939d0f4ba72144d29
	style.ChildWindowRounding = 3.f;
	style.GrabRounding = 0.f;
	style.WindowRounding = 0.f;
	style.ScrollbarRounding = 3.f;
	style.FrameRounding = 3.f;
	style.WindowTitleAlign = ImVec2(0.5f,0.5f);

	style.Colors[ImGuiCol_Text]                  = ImVec4(0.73f, 0.73f, 0.73f, 1.00f);
	style.Colors[ImGuiCol_TextDisabled]          = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
	style.Colors[ImGuiCol_WindowBg]              = ImVec4(0.26f, 0.26f, 0.26f, 0.95f);
	style.Colors[ImGuiCol_ChildWindowBg]         = ImVec4(0.28f, 0.28f, 0.28f, 1.00f);
	style.Colors[ImGuiCol_PopupBg]               = ImVec4(0.26f, 0.26f, 0.26f, 1.00f);
	style.Colors[ImGuiCol_Border]                = ImVec4(0.26f, 0.26f, 0.26f, 1.00f);
	style.Colors[ImGuiCol_BorderShadow]          = ImVec4(0.26f, 0.26f, 0.26f, 1.00f);
	style.Colors[ImGuiCol_FrameBg]               = ImVec4(0.16f, 0.16f, 0.16f, 1.00f);
	style.Colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.16f, 0.16f, 0.16f, 1.00f);
	style.Colors[ImGuiCol_FrameBgActive]         = ImVec4(0.16f, 0.16f, 0.16f, 1.00f);
	style.Colors[ImGuiCol_TitleBg]               = ImVec4(0.36f, 0.36f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(0.36f, 0.36f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_TitleBgActive]         = ImVec4(0.36f, 0.36f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_MenuBarBg]             = ImVec4(0.26f, 0.26f, 0.26f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarBg]           = ImVec4(0.21f, 0.21f, 0.21f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.36f, 0.36f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(0.36f, 0.36f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(0.36f, 0.36f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_ComboBg]               = ImVec4(0.32f, 0.32f, 0.32f, 1.00f);
	style.Colors[ImGuiCol_CheckMark]             = ImVec4(0.78f, 0.78f, 0.78f, 1.00f);
	style.Colors[ImGuiCol_SliderGrab]            = ImVec4(0.74f, 0.74f, 0.74f, 1.00f);
	style.Colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.74f, 0.74f, 0.74f, 1.00f);
	style.Colors[ImGuiCol_Button]                = ImVec4(0.36f, 0.36f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_ButtonHovered]         = ImVec4(0.43f, 0.43f, 0.43f, 1.00f);
	style.Colors[ImGuiCol_ButtonActive]          = ImVec4(0.11f, 0.11f, 0.11f, 1.00f);
	style.Colors[ImGuiCol_Header]                = ImVec4(0.36f, 0.36f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_HeaderHovered]         = ImVec4(0.36f, 0.36f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_HeaderActive]          = ImVec4(0.36f, 0.36f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_Column]                = ImVec4(0.39f, 0.39f, 0.39f, 1.00f);
	style.Colors[ImGuiCol_ColumnHovered]         = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_ColumnActive]          = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_ResizeGrip]            = ImVec4(0.36f, 0.36f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_ResizeGripHovered]     = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_ResizeGripActive]      = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_CloseButton]           = ImVec4(0.59f, 0.59f, 0.59f, 1.00f);
	style.Colors[ImGuiCol_CloseButtonHovered]    = ImVec4(0.98f, 0.39f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_CloseButtonActive]     = ImVec4(0.98f, 0.39f, 0.36f, 1.00f);
	style.Colors[ImGuiCol_PlotLines]             = ImVec4(0.39f, 0.39f, 0.39f, 1.00f);
	style.Colors[ImGuiCol_PlotLinesHovered]      = ImVec4(1.00f, 0.43f, 0.35f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogram]         = ImVec4(0.90f, 0.70f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(1.00f, 0.60f, 0.00f, 1.00f);
	style.Colors[ImGuiCol_TextSelectedBg]        = ImVec4(0.32f, 0.52f, 0.65f, 1.00f);
	style.Colors[ImGuiCol_ModalWindowDarkening] = ImVec4(0.20f, 0.20f, 0.20f, 0.50f);

    }
    break;
    default:
    break;
    } 

    return true;
}
static const char* DefaultStyleNames[ImGuiStyle_Count]={"Default","Gray","Light","OSX","OSXOpaque","DarkOpaque","Soft","EdinBlack","EdinWhite","Maya","DefaultInverse","OSXInverse","OSXOpaqueInverse","DarkOpaqueInverse"};
const char** GetDefaultStyleNames() {return &DefaultStyleNames[0];}

} // namespace ImGui


