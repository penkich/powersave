; for ATTiny13A（ヒューズビットは、買ってきたまま）
; Timer0 を使って、１時間に１分間だけLEDをONにしてみたい。ただそれだけ。
; 2019-06-28 by penkich
;
.equ LED_PIN = PB0	; use PB0 as LED pin
.def tmp = r16
.def loop1 = r17
.def loop2 = r18
.def flag = r19
.equ time_len = 250	; 適当に調節したら６０分になるか？
.equ ratio = 59		; ONに対するOFFの時間の比率

.org	0x0000
	rjmp main

.org    OVF0addr	; Timer0 Overflowの割り込みアドレス
	rjmp OVF_isr	; jump to label OVF_isr

main:
    cli ; 割り込み禁止
    sbi DDRB, LED_PIN	; set LED pin as output
    ldi tmp, 0x05       ; プリスケーラ 5: 1024分の1
    out TCCR0B, tmp		; 
    ldi tmp, 0x00       ; カウンター
    out TCNT0, tmp
    ldi	tmp, (1<<TOIE0)	; オーバーフロー割り込み許可
    out	TIMSK0, tmp	; ここは、outでないとダメ!
    ldi loop1, ratio
    ldi loop2, time_len
    ldi flag, 1
    sei ; 割り込み許可
loop:
    nop
    nop
    nop
    rjmp loop

OVF_isr:		; Timer0 オーバーフロー割り込みルーチン
    dec loop2
    brne next2

    dec loop1
    brne next

    ldi tmp, 0b00000001
    out PORTB, tmp
    ldi    loop1, ratio
    ldi loop2, time_len
    reti

next:			; ポートをOFF
    ldi tmp, 0b00000000
    out PORTB, tmp
    ldi loop2, time_len
    reti
    
next2:
    reti
