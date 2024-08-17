import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def top(dut):
    dut._log.info("start")
    # 25.175MHz => 0.000_000_039_722s
    clock = Clock(dut.clk, 39722, units="ps")
    cocotb.start_soon(clock.start())
    
#    dut._log.info("reset")
#    dut.rst.value = 1
#    await ClockCycles(dut.clk, 10)
#    dut.rst.value = 0

    await ClockCycles(dut.clk, 1000)
