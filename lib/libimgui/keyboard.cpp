/**
 * 作者:evilbinary on 12/24/16.
 * 邮箱:rootdebug@163.com 
 */

#include "keyboard.h"


static int lookupValueByLabel(const char* literal, const KeycodeLabel *list) {
    while (list->literal) {
        if (strcmp(literal, list->literal) == 0) {
            return list->value;
        }
        list++;
    }
    return list->value;
}

static const char* lookupLabelByValue(int value, const KeycodeLabel *list) {
    while (list->literal) {
        if (list->value == value) {
            return list->literal;
        }
        list++;
    }
    return NULL;
}

char* getLabelByValue(int value){
    return lookupLabelByValue(value,KEYCODES );
}
