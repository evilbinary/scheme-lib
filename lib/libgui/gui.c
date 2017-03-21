/**
 * 作者:evilbinary on 12/24/16.
 * 邮箱:rootdebug@163.com 
 */


#include "nanovg.h"
#include <stdio.h>
#include <string.h>
#include <math.h>

//static float minf(float a, float b) { return a < b ? a : b; }
static float maxf(float a, float b) { return a > b ? a : b; }
//static float absf(float a) { return a >= 0.0f ? a : -a; }
static float clampf(float a, float mn, float mx) { return a < mn ? mn : (a > mx ? mx : a); }


void drawTip(NVGcontext* vg,float x ,float y,char* text,int breakWidth ){
  float px;
  float bounds[4];
  float a;
  float gx,gy;
  float mx,my;
  nvgFontSize(vg, 13.0f);
  nvgTextAlign(vg, NVG_ALIGN_LEFT|NVG_ALIGN_TOP);
  nvgTextLineHeight(vg, 1.2f);
  nvgTextBoxBounds(vg, x,y, breakWidth, text, NULL, bounds);

  gx = fabsf((mx - (bounds[0]+bounds[2])*0.5f) / (bounds[0] - bounds[2]));
  gy = fabsf((my - (bounds[1]+bounds[3])*0.5f) / (bounds[1] - bounds[3]));
  a = maxf(gx, gy) - 0.5f;
  a = clampf(a, 0, 1);
  nvgGlobalAlpha(vg, a);

  nvgBeginPath(vg);
  nvgFillColor(vg, nvgRGBA(220,220,220,255));
  nvgRoundedRect(vg, bounds[0]-2,bounds[1]-2, (int)(bounds[2]-bounds[0])+4, (int)(bounds[3]-bounds[1])+4, 3);
  px = (int)((bounds[2]+bounds[0])/2);
  nvgMoveTo(vg, px,bounds[1] - 10);
  nvgLineTo(vg, px+7,bounds[1]+1);
  nvgLineTo(vg, px-7,bounds[1]+1);
  nvgFill(vg);

  nvgFillColor(vg, nvgRGBA(0,0,0,220));
  nvgTextBox(vg, x,y, breakWidth, text, NULL);
}




void calcCursorPos(NVGcontext* vg, float x, float y, float width, float height, float mx, float my,char* text,float *xx,float* yy,int* crow,int* ccol,int* rowNumber,int*ccols)
{
  NVGtextRow rows[3];
  NVGglyphPosition glyphs[100];
  
  const char* start;
  const char* end;
  int nrows, i, nglyphs, j, lnum = 0;
  float lineh;
  float caretx, px;
  float bounds[4];
  float a;
  float gx,gy;
  int gutter = 0;
  int total=0;
  int isEnd=0;
  
  NVG_NOTUSED(height);

  nvgSave(vg);

  nvgFontSize(vg, 20.0f);
  nvgFontFace(vg, "sans");
  nvgTextAlign(vg, NVG_ALIGN_LEFT|NVG_ALIGN_TOP);
  nvgTextMetrics(vg, NULL, NULL, &lineh);

  start = text;
  end = text + strlen(text);
  while ((nrows = nvgTextBreakLines(vg, start, end, width, rows, 3))) {
      
    for (i = 0; i < nrows; i++) {
      NVGtextRow* row = &rows[i];
      int hit = mx > x && mx < (x+width) && my >= y && my < (y+lineh);
      if (hit) {
      	caretx = (mx < x+row->width/2) ? x : x+row->width;
      	px = x;
      	nglyphs = nvgTextGlyphPositions(vg, x, y, row->start, row->end, glyphs, 100);
      	for (j = 0; j < nglyphs; j++) {
      	  float x0 = glyphs[j].x;
      	  float x1 = (j+1 < nglyphs) ? glyphs[j+1].x : x+row->width;
      	  float gx = x0 * 0.3f + x1 * 0.7f;
      	  if (mx >= px && mx < gx){
      	    caretx = glyphs[j].x;
	    *ccol=j;
	    isEnd=j;
	    total+=j;
	  }
      	  px = gx;
      	}
		  
	*crow=lnum;
	*yy=y;
	*xx=caretx;
	
      	gutter = lnum+1;
      	gx = x - 10;
      	gy = y + lineh/2;
      }
      if(isEnd==0){
	total+=(row->end-row->start)+1;
      }
      
      lnum++;
      y += lineh;

    }
    start = rows[nrows-1].next;

  }
  *rowNumber=lnum;
  printf("toal=%d\n",total);
  *ccols=total;
  y += 20.0f;

}


void drawParagraph(NVGcontext* vg, float x, float y, float width, float height, float mx, float my,char* text)
{
  NVGtextRow rows[3];
  NVGglyphPosition glyphs[100];
	
  const char* start;
  const char* end;
  int nrows, i, nglyphs, j, lnum = 0;
  float lineh;
  float caretx, px;
  float bounds[4];
  float a;
  float gx,gy;
  int gutter = 0;
  NVG_NOTUSED(height);

  nvgSave(vg);

  nvgFontSize(vg, 20.0f);
  nvgFontFace(vg, "sans");
  nvgTextAlign(vg, NVG_ALIGN_LEFT|NVG_ALIGN_TOP);
  nvgTextMetrics(vg, NULL, NULL, &lineh);

  start = text;
  end = text + strlen(text);
  while ((nrows = nvgTextBreakLines(vg, start, end, width, rows, 3))) {
    for (i = 0; i < nrows; i++) {
      NVGtextRow* row = &rows[i];
      int hit = mx > x && mx < (x+width) && my >= y && my < (y+lineh);

      nvgBeginPath(vg);
      //nvgFillColor(vg, nvgRGBA(255,255,255,hit?64:16));
      //nvgRect(vg, x, y, row->width, lineh);
      //nvgFill(vg);

      nvgFillColor(vg, nvgRGBA(255,255,255,255));
      nvgText(vg, x, y, row->start, row->end);
      
      /* if (hit) { */
      /* 	caretx = (mx < x+row->width/2) ? x : x+row->width; */
      /* 	px = x; */
      /* 	nglyphs = nvgTextGlyphPositions(vg, x, y, row->start, row->end, glyphs, 100); */
      /* 	for (j = 0; j < nglyphs; j++) { */
      /* 	  float x0 = glyphs[j].x; */
      /* 	  float x1 = (j+1 < nglyphs) ? glyphs[j+1].x : x+row->width; */
      /* 	  float gx = x0 * 0.3f + x1 * 0.7f; */
      /* 	  if (mx >= px && mx < gx) */
      /* 	    caretx = glyphs[j].x; */
      /* 	  px = gx; */
      /* 	} */
      /* 	nvgBeginPath(vg); */
      /* 	nvgFillColor(vg, nvgRGBA(255,192,0,255)); */
      /* 	nvgRect(vg, caretx, y, 1, lineh); */
      /* 	nvgFill(vg); */

      /* 	gutter = lnum+1; */
      /* 	gx = x - 10; */
      /* 	gy = y + lineh/2; */
      /* } */
      lnum++;
      y += lineh;
    }
    // Keep going...
    start = rows[nrows-1].next;
  }

  if (gutter) {
    char txt[16];
    snprintf(txt, sizeof(txt), "%d", gutter);
    nvgFontSize(vg, 13.0f);
    nvgTextAlign(vg, NVG_ALIGN_RIGHT|NVG_ALIGN_MIDDLE);

    nvgTextBounds(vg, gx,gy, txt, NULL, bounds);

    nvgBeginPath(vg);
    nvgFillColor(vg, nvgRGBA(255,192,0,255));
    nvgRoundedRect(vg, (int)bounds[0]-4,(int)bounds[1]-2, (int)(bounds[2]-bounds[0])+8, (int)(bounds[3]-bounds[1])+4, ((int)(bounds[3]-bounds[1])+4)/2-1);
    nvgFill(vg);

    nvgFillColor(vg, nvgRGBA(32,32,32,255));
    nvgText(vg, gx,gy, txt, NULL);
  }

  y += 20.0f;

  //drawTip(vg,x,y,text,150);

  nvgRestore(vg);
}







