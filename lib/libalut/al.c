#include "al.h"


ALuint al_gen_source(ALsizei n){
	ALuint i;
	alGenSources(n,&i);
	return i;
}