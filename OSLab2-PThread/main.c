#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <time.h>

#define TOTAL 10

int goods = 2;

pthread_mutex_t mutex;
pthread_cond_t max;
pthread_cond_t one;
pthread_t producer_id;
pthread_t customer_id;

void *producer(void *agv) {
    while (1) {
        pthread_mutex_lock(&mutex);
        printf("producer lock\n");
        sleep(rand()%2);
        goods++;
        printf("I am producer and the goods left %d\n", goods);
        if (goods == TOTAL){
            printf("It is enough! Producer sleep!\n");
            printf("producer unlock\n");
            pthread_cond_wait(&max, &mutex);
        }
        if (goods == 1){
            printf("It' time to wake up customer\n");
            pthread_cond_signal(&one);
        }
        printf("producer unlock\n");
        pthread_mutex_unlock(&mutex);
        sleep(1 + rand()%3);
    }
    pthread_exit(0);
}

void *customer(void *arv) {
    while (1) {
        pthread_mutex_lock(&mutex);
        printf("customer lock\n");
        sleep(rand()%2);
        goods--;
        printf("I am customer and the goods left %d\n", goods);
        if (goods == 0){
            printf("It is none! Customer sleep!\n");
            printf("customer unlock\n");
            pthread_cond_wait(&one, &mutex);
        }
        if (goods == TOTAL - 1){
            printf("It' time to wake up producer\n");
            pthread_cond_signal(&max);
        }
        printf("customer unlock\n");
        pthread_mutex_unlock(&mutex);
        sleep(1 + rand()%2);
    }
    pthread_exit(0);
}

int main()
{
    srand(time(0));
    pthread_mutex_init (&mutex, NULL);
    pthread_cond_init(&max, NULL);
    pthread_cond_init(&one, NULL);
    int produce_id = pthread_create(&producer_id, NULL, producer, NULL);
    int custome_id = pthread_create(&customer_id, NULL, customer, NULL);
    pthread_join(producer_id, NULL);
    pthread_join(customer_id, NULL);
    pthread_cond_destroy(&max);
    pthread_cond_destroy(&one);
    pthread_mutex_destroy(&mutex);
    return 0;
}