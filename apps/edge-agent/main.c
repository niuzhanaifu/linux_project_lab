#include <stdio.h>

#define EDGE_AGENT_VERSION "0.1.0"
#define EDGE_DEVICE_ID "student_demo"

int main(void)
{
    printf("edge-agent: version=%s\n", EDGE_AGENT_VERSION);
    printf("edge-agent: device_id=%s\n", EDGE_DEVICE_ID);
    printf("edge-agent: transport=loopback\n");
    fflush(stdout);
    return 0;
}

