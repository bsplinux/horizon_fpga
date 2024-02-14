#ifndef COMMONDEF_H
#define COMMONDEF_H


#ifdef __cplusplus
extern "C" {
#endif
#ifndef VAR_FOURCC
#define VAR_FOURCC( a, b, c, d ) \
        ( ((unsigned int )a) | ( ((unsigned int)b) << 8 ) \
           | ( ((unsigned int)c) << 16 ) | ( ((unsigned int)d) << 24 ) )
#endif           
#define VAR_TWOCC( a, b ) \
        ( (unsigned short)(a) | ( (unsigned short)(b) << 8 ) )

#if !defined(_MIN)
#define _MIN(a,b) (((a) <= (b)) ? (a ) : (b))
#endif

#if !defined(_MAX)
#define _MAX(a,b) (((a) > (b)) ? (a ) : (b))
#endif

#if !defined(BIT)
#define BIT(b) (1<<(b))
#endif

#if !defined(BITVAL)
#define BITVAL(v,b,s) (((v)>>(b)) & ((1<<(s)) -1))
#endif

#if !defined(BITSIFTR)
#define BITSIFTR(val,bit,cnt,newp)	(((val>>bit) & ((1<<(cnt)) -1))<<(newp))
#endif


#ifndef CLEAR
#define CLEAR(a) memset((void*)(&a),0,sizeof(a))
#endif

#ifdef __cplusplus
}
#endif


#endif

