#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <errno.h>
#include <sys/queue.h>
//以上头开发环境glibc的相关头文件
#include <rte_memory.h>
#include <rte_memzone.h>
#include <rte_launch.h>
#include <rte_eal.h>
#include <rte_per_lcore.h>
#include <rte_lcore.h>
#include <rte_debug.h>
 
static int lcore_hello(__attribute__((unused)) void *arg)
{
 
    unsigned lcore_id;
    lcore_id = rte_lcore_id(); //获取逻辑核编号，并输出逻辑核id，返回，线程退出。
    printf("hello from core %u\n", lcore_id);
    return 0;
}
 
int main(int argc, char **argv)
{
    int ret;
    unsigned lcore_id;
    /* 相关初始化工作，如命令含参数处理，自动检测环境相关条件。以及相关库平台初始化工作*/
    ret = rte_eal_init(argc, argv);
    if (ret < 0)
        rte_panic("Cannot init EAL\n");
 
    /* 每个从逻辑核调用回调函数lcore_hello输出相关信息。 */
    /*给出RTE_LCORE_FOREACH_SLAVE宏定义
    #define RTE_LCORE_FOREACH_SLAVE(i)                  \
    for (i = rte_get_next_lcore(-1, 1, 0);              \
         i<RTE_MAX_LCORE;                       \
         i = rte_get_next_lcore(i, 1, 0))
    */
    RTE_LCORE_FOREACH_WORKER(lcore_id) 
    {
        rte_eal_remote_launch(lcore_hello, NULL, lcore_id);
    }
 
    /* 再次调用主逻辑核输出相关信息。 */
    lcore_hello(NULL);
    /* 等待所有从逻辑核调用返回，相当于主线程阻塞等待。*/
    rte_eal_mp_wait_lcore();
    return 0;
}

