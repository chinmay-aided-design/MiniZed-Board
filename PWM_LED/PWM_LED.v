module pwmLED_Fader (
    input clk,          // 100 MHz clock from Zynq PS
    input reset_n,
    output PL_LED_G    // Green LED output
);

// --- 1. Fast PWM Generator (for high-frequency dimming) ---
// 8-bit counter gives 256 steps of brightness resolution
reg [7:0] pwm_counter = 8'd0;
reg [7:0] duty_cycle_reg = 8'd0; // This value changes slowly to fade the LED

// PWM Clock is 100MHz / 256 cycles ≈ 390.625 kHz (Too fast for human eye, perfect for dimming)
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        pwm_counter <= 8'd0;
    end else begin
        pwm_counter <= pwm_counter + 1;
    end
end

// Output is HIGH when the counter is less than the Duty Cycle
assign PL_LED_G = (pwm_counter < duty_cycle_reg);

// --- 2. Slow Fading Ramp Generator ---
// Used to slow down the 100MHz clock to a visible fade rate
reg [24:0] clock_divider_count = 25'd0;
reg next_duty_cycle_flag = 1'b0; // Flag to indicate it's time to adjust brightness

// Fading state: 0=Fading Up, 1=Fading Down
reg fade_direction = 1'b0;

// Creates a slow tick (approx 0.33 seconds per tick)
// (2^25 / 100MHz) * 2 = ~0.67 seconds for one full ramp cycle
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        clock_divider_count <= 25'd0;
        next_duty_cycle_flag <= 1'b0;
    end else if (clock_divider_count == 25'd33000000) begin // ~0.33 seconds
        clock_divider_count <= 25'd0;
        next_duty_cycle_flag <= 1'b1; // Raise flag to change duty cycle
    end else begin
        clock_divider_count <= clock_divider_count + 1;
        next_duty_cycle_flag <= 1'b0;
    end
end

// Logic to automatically ramp the duty cycle up and down
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        duty_cycle_reg <= 8'd0;
        fade_direction <= 1'b0;
    end else if (next_duty_cycle_flag) begin
        if (fade_direction == 1'b0) begin // Fading UP
            if (duty_cycle_reg == 8'hFF) // Reached Max Brightness
                fade_direction <= 1'b1;
            else
                duty_cycle_reg <= duty_cycle_reg + 1;
        end else begin // Fading DOWN
            if (duty_cycle_reg == 8'd0) // Reached Min Brightness
                fade_direction <= 1'b0;
            else
                duty_cycle_reg <= duty_cycle_reg - 1;
        end
    end
end

endmodule
