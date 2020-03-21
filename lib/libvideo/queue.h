/*
 * Queue.h
 *
 *  Created on: May 30, 2011
 *      Author: 小E qq592646022
 */
#ifndef QUEUE_H_
#define QUEUE_H_

#define SIZE 256
#define INCRESIZE 100
#define true 1
#define false 0

typedef void* type;
typedef struct queue
{
  int is_auto_size;
  int size,len;
  int fron,rear;
  type* data;
}* pQueue,Queue;

void queue_init_with_size(pQueue Q,int size){
  Q->data=malloc(sizeof(type)*size);
  Q->fron=0;
  Q->rear=0;
  Q->size=size;
  Q->len=0;
  Q->is_auto_size=0; 
}

void queue_init(pQueue Q)	//队列初始化
{
  Q->data=malloc(sizeof(type)*SIZE);
  Q->fron=0;
  Q->rear=0;
  Q->size=SIZE;
  Q->len=0;
  Q->is_auto_size=0;
  
}

int queue_empty(pQueue Q){	//判断是否为空
  if( Q->fron==Q->rear&&Q->len<=0 )
    return true;
  return false;
}

int queue_get_length(pQueue Q){
  return Q->len;
}

int queue_is_full(pQueue Q){
  if( (Q->rear+1)%Q->size == Q->fron ){
    return true;
  }
  return false;
}

void queue_incre(pQueue Q){//增加长度
  int len;
  type* t;
  t=malloc(sizeof(type)*(Q->size+INCRESIZE));
  for(len=0;len<queue_get_length(Q);len++){
      t[len]=Q->data[Q->fron%(Q->size)];
      Q->fron++;
  }
  free(Q->data);
  
  Q->data=t;
  Q->fron=0;
  Q->rear=len-1;
  Q->size+=INCRESIZE;
}

int queue_in(pQueue Q,type e){	//入队列
  if(queue_is_full(Q)==true) {
    if(Q->is_auto_size==1){
      queue_incre(Q);
      
    }else{
      //printf("queue %p is full\n",Q);
      return false;
    }
  }
  //printf("in %p %p\n",Q,e);
  Q->data[Q->rear]=e;
  Q->rear=(Q->rear+1)%Q->size;
  Q->len++;
  
  return true;
}

type queue_out(pQueue Q){	//入队列
  type tmp=NULL;
  
  if(queue_empty(Q)){
    //printf("队列为空操作失败\n");
      return tmp;
  }else{
      tmp=Q->data[Q->fron];
      Q->fron=(Q->fron+1)%Q->size ;
      Q->len--;
  }
  //printf("out %p %p\n",Q,tmp );
  return tmp;
}

void queue_trav(pQueue Q){	//遍历队列显示结果
  int i;
  for(i = Q->fron; i != Q->rear; i=(i+1)%Q->size){
    printf(" %d ",Q->data[i]);
  }
}

type queue_get_head(pQueue Q){	//取队头元素
  type a=NULL;
  if(queue_empty(Q))
    return a;
  return Q->data[Q->fron];
}
#endif /* QUEUE_H_ */
