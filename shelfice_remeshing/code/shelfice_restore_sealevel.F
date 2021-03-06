#include "SHELFICE_OPTIONS.h"
#ifdef ALLOW_OBCS
# include "OBCS_OPTIONS.h"
#endif

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: SHELFICE_FORCING_SURF
C     !INTERFACE:
      SUBROUTINE SHELFICE_RESTORE_SEALEVEL(
     I           bi, bj, iMin, iMax, jMin, jMax,
     I           myTime, myIter, myThid )
C     !DESCRIPTION: \bv
C     *==========================================================*
C     | S/R SHELFICE_FORCING_SURF
C     | o Contains problem specific surface forcing
C     *==========================================================*
C     \ev

C     !USES:
      IMPLICIT NONE
C     == Global data ==
#include "SIZE.h"
#include "EEPARAMS.h"
#ifdef UNFINISHED_LOCAL_CODE
# include "PARAMS.h"
# include "GRID.h"
# include "DYNVARS.h"
# include "SURFACE.h"
# include "FFIELDS.h"
# include "SHELFICE.h"
# include "OBCS_PARAMS.h"
# include "OBCS_GRID.h"
# include "OBCS_FIELDS.h"
#endif /* UNFINISHED_LOCAL_CODE */

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     bi,bj     :: Current tile indices
C     iMin,iMax :: Working range of x-index for applying forcing.
C     jMin,jMax :: Working range of y-index for applying forcing.
C     myTime    :: Current time in simulation
C     myIter    :: Current iteration number in simulation
C     myThid    :: Thread Id number
      INTEGER bi, bj
      INTEGER iMin, iMax, jMin, jMax
      _RL myTime
      INTEGER myIter
      INTEGER myThid

#ifdef UNFINISHED_LOCAL_CODE
C     !LOCAL VARIABLES:
C     == Local variables ==
C     i,j   :: Loop counters
      INTEGER i, j, jsl
      _RL etarelax, lambda_obcs_t
CEOP

c     DO bj=myByLo(myThid),myByHi(myThid)
c      DO bi=myBxLo(myThid),myBxHi(myThid)

C--   Zero out surface forcing terms below ice-shelf

       IF (shelfice_etarestore_spongewidth.eq.0) then
        shelfice_etarestore_spongewidth = spongeThickness
       ENDIF

       IF (shelficeetarelax.eq.0.0) then
        shelficeetaRelax = Vrelaxobcsbound
       ENDIF

#ifdef ALLOW_OBCS_NORTH
       IF ( OBCSsponge_N .AND. shelficeEtaSponge ) THEN
        DO i=1,sNx
         IF ( OB_Jn(i,bi,bj).NE.OB_indexNone ) THEN
          DO jsl= 1,shelfice_etarestore_spongewidth-1
           j=OB_Jn(i,bi,bj)-jsl
           IF ((j.ge.jmin).and.(j.le.jmax)) THEN
             IF (.true.) THEN
              etarelax = OBNeta(i,bi,bj)
             ELSE
              etarelax=(
     &       float(shelfice_etarestore_spongewidth-jsl)*OBNeta(i,bi,bj)
     &             + float(jsl)*etan(i,j,bi,bj) )
     &             / float(shelfice_etarestore_spongewidth)
             ENDIF
             lambda_obcs_t = (
     &            float(jsl)*shelficeEtaRelax
     &            + float(jsl)*Vrelaxobcsinner)
     &            / float(shelfice_etarestore_spongewidth)
             IF (lambda_obcs_t.ne.0.) THEN
              lambda_obcs_t = 1. _d 0 / lambda_obcs_t
             ELSE
              lambda_obcs_t = 0. _d 0
             ENDIF
             EmPmR(i,j,bi,bj) =
     &              maskInC(i,j,bi,bj) * lambda_obcs_t
     &            * ( etan(i,j,bi,bj) - etarelax ) * rhoConst
           ENDIF
          ENDDO
         ENDIF
        ENDDO
       ENDIF
#endif

c      ENDDO
c     ENDDO

#endif /* UNFINISHED_LOCAL_CODE */
      RETURN
      END
