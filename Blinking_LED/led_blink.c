#include "xparameters.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "sleep.h"

#define XPAR_AXI_GPIO_0_DEVICE_ID 0  // Manually define device ID
#define LED_CHANNEL 1
#define LED_ON  0x01
#define LED_OFF 0x00

int main(void)
{
    XGpio Gpio;
    int status;

    xil_printf("MiniZed PL LED Control Example\r\n");

    // Initialize GPIO driver
    status = XGpio_Initialize(&Gpio, XPAR_AXI_GPIO_0_DEVICE_ID);
    if (status != XST_SUCCESS) {
        xil_printf("GPIO Initialization Failed\r\n");
        return XST_FAILURE;
    }

    // Set direction: 0 = output
    XGpio_SetDataDirection(&Gpio, LED_CHANNEL, 0x00);

    while (1) {
        xil_printf("LED ON\r\n");
        XGpio_DiscreteWrite(&Gpio, LED_CHANNEL, LED_ON);
        sleep(1);

        xil_printf("LED OFF\r\n");
        XGpio_DiscreteWrite(&Gpio, LED_CHANNEL, LED_OFF);
        sleep(1);
    }

    return 0;
}
