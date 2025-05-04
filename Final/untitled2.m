clear all;
close all;

a = arduino('COM3', 'Leonardo');
writeDigitalPin(a,"D12", 1);