MODULE B_Spline
CONTAINS
SUBROUTINE bspline(nr,gridmin,gridmax,pcons,fes)
!*****************************************************************************************
    USE bspline_module
    USE bspline_kinds_module, only: wp, ip
!    USE pyplot_module

    IMPLICIT NONE

    INTEGER(ip)                 :: nx           !! number of points in x
    INTEGER(ip)                 :: nxv          !! number of points to evaluate interpolant
    INTEGER(ip),PARAMETER       :: kx    = 4    !! order in x
    INTEGER(ip),PARAMETER       :: iknot = 0    !! automatically select the knots

    INTEGER                     :: istat  !! pyplot-fortran status flag
    INTEGER(ip)                 :: i,j,idx,iflag,inbvx,iloy
    INTEGER                     :: n,nr,ios
    REAL(wp),ALLOCATABLE        :: x(:),f1(:),fval(:)
    REAL(wp),ALLOCATABLE        :: xval(:)
    REAL(wp),ALLOCATABLE        :: tx(:)
    REAL(wp)                    :: val,tru,err,errmax,gridmin(*),gridmax(*)
    REAL(wp),DIMENSION(3*kx)    :: w1_1d !! work array
    LOGICAL                     :: extrap
!    type(pyplot) :: plt
    REAL*8                      :: pcons(*),fes(*)
    REAL*8                      :: dummy,dummy1,nb

    idx = 0
    nx = nr ; nxv = 10*(nr)
    ALLOCATE(x(nx))
    ALLOCATE(xval(nxv))
    ALLOCATE(tx(nx+kx))
    ALLOCATE(f1(nx))
    ALLOCATE(fval(nxv))
    
    DO i = 1,nr
      x(i)  = pcons(i)
      f1(i) = fes(i)
!      WRITE(*,*)pcons(i),fes(i)
    ENDDO

    !nb = (gridmax(1) - gridmin(1))/nxv
    nb = (pcons(nr) - pcons(2))/nxv
    DO i = 1,nxv
      xval(i) = pcons(2)+nb*i
    ENDDO
    !have to set these before the first evaluate call:
    inbvx = 1
    iloy  = 1
    ! initialize
    CALL db1ink(x,nx,f1,kx,iknot,tx,f1,iflag)

    IF (iflag/=0) THEN
        WRITE(*,*) 'Error initializing 1D spline: '//get_status_message(iflag)
    END IF

    !initialize the plot:
!    call plt%initialize(grid=.true.,xlabel='x (deg)',ylabel='f(x)',&
!                        title='Extrapolation Test',legend=.true.)
!    call plt%add_plot(x,f1,label='free_energy$',&
!                        linestyle='ko',markersize=5,linewidth=2,istat=istat)

        OPEN(21,FILE='interp_free_energy.out')
        errmax = 0.0_wp
        DO i=1,nxv
            call db1val(xval(i),idx,tx,nx,kx,f1,val,iflag,inbvx,w1_1d,extrap=extrap)
!            write(*,*) xval(i), val
            IF (xval(i) .lt. pcons(1)) val = 0.0
            fval(i) = val  ! save it for plot
            WRITE(21,*)xval(i), val
        END DO

        WRITE(*,*) ''
        WRITE(*,*) 'interpolated free energy written in : interp_free_energy.dat'
        WRITE(*,*) ''

!        if (extrap) then
!            call plt%add_plot(xval,fval,&
!                    label='Interpolated',&
!                    linestyle='g.-',linewidth=1,istat=istat)
!            call plt%savefig('bspline_extrap_test.png',istat=istat)
!        end if


DEALLOCATE(x)
DEALLOCATE(xval)
DEALLOCATE(f1)
CLOSE(21)
END
END MODULE B_Spline
