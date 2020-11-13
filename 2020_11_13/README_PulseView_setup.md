
The [orangepishield_06_alljumpers_3lamps_rdmdisco_fail_cal_pv.wav](orangepishield_06_alljumpers_3lamps_rdmdisco_fail_cal_pv.wav) is a conversion of the Saleae Logic analog capture of the DMX- and DMX+ signal lines, shown in the video [VID_20201113_090735.mp4](VID_20201113_090735.mp4); to visualise it in PulseView:

* Start new session in PulseView
* Use `Import Microsoft WAV file format data...` and import [orangepishield_06_alljumpers_3lamps_rdmdisco_fail_cal_pv.wav](orangepishield_06_alljumpers_3lamps_rdmdisco_fail_cal_pv.wav)
* Two analog channels get imported, auto-named `CH1` and `CH2`
* Click on `CH1` label, rename it to `CH1_DMXi`, since this is the DMX inverting line
* Click on `CH2` label, rename it to `CH2_DMXn`, since this is the DMX non-inverting line
* Add a math channel (available in new nightlies in PulseView), set it up as shown in [Pulseview_settings.png](Pulseview_settings.png)
* After having obtained the patched UART decoder pd.py in PulseView (as per [../get_patch_pulseview_uart_pd.sh](../get_patch_pulseview_uart_pd.sh)) - add a UART decoder to the PulseView sessiong, and set it up as shown in [Pulseview_settings.png](Pulseview_settings.png)
* Done - this is how [orangepishield_06_alljumpers_3lamps_rdmdisco_fail_cal_pv_PulseView.png](orangepishield_06_alljumpers_3lamps_rdmdisco_fail_cal_pv_PulseView.png) was obtained
