! Copyright (c) 2013, Paul Muir, Jack Pew
! Paul Muir, Mathematics and Computing Science, Saint Mary's University.
! All rights reserved.
!
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions
! are met:
! * Redistributions of source code must retain the above copyright
!   notice, this list of conditions and the following disclaimer.
! * Redistributions in binary form must reproduce the above copyright
!   notice, this list of conditions and the following disclaimer in the
!   documentation and/or other materials provided with the distribution.
!
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
! "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
! LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
! A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
! HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
! LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
! DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
! THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
! (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
! OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

program simple_example_driver

    ! A minimal example driver for the EBACOLI95 wrapper of EBACOLI.
    ! See the comments within ebacoli95.f95 for details regarding use.

    use ebacoli95_mod, only: ebacoli95_init, ebacoli95, ebacoli95_vals, &
                            ebacoli95_sol, ebacoli95_sol_teardown

    implicit none
    integer, parameter  :: dp = kind(0d0)

    ! Declare data structure that will hold solution
    type(ebacoli95_sol)  :: sol

    ! Choose npde to be consistent with the problem specific source
    ! code; see burg1.f, burg2.f, CahnAllen.f, rcdsys.f, sinmads.f,
    ! and steady.f.
    ! Assume output at 11 points over (problem specific) spatial domain,
    ! and maximum number of subintervals = 50.
    integer,  parameter, dimension(3) :: npde_sub = (/2,0,0/)
    integer,  parameter :: npde = 2, nu = 2, nv = 0, nw = 0, nout = 11, nint_max = 5000
    real(dp), parameter :: xa = 0, xb = 1
    integer,  parameter :: nin = 100
    real(dp) :: xin(nin)
    ! Set (problem dependent) output time to 1
    real(dp), parameter :: tout = 1.0D1

    ! Declare output points and output solution values arrays
    real(dp) :: xout(nout), uout(npde*nout)

    integer :: i, k, ij

    external f, bndxa, bndxb, uinit, derivf, difbxa, difbxb

    ! parameters
    double precision    D, chi, tau
    common /chemotaxis/   D, chi, tau
    D = 0.1d0
    chi = 5.d0
    tau = 1.0d0 ! singular chemotaxis when tau=0


    ! Initialize a grid to pass to ebacoli
    xin = (/(xa+i*(xb-xa)/(nin-1), i=0,nin-1)/)

    write(*,*) xin

    ! Initialization (set spatial domain = [0,1]); a default uniform
    ! spatial mesh having 10 subintervals will be constructed.
    call ebacoli95_init(sol, npde_sub, xin, atol=(/1d-6/), &
         rtol=(/1d-6/), nint_max = nint_max)

    call write_subsystem_sizes(sol%npde_sub)

    ! Compute solution at tout
    call ebacoli95(sol, tout, f, bndxa, bndxb, uinit, derivf, difbxa, difbxb)

    ! Output idid to check for a successful computation
    print '("idid=",i5)',sol%idid
    if (sol%idid > 0) print '("idid > 0 => Successful computation")'

    ! Output solution at tout for nout values of x uniformly
    ! distributed over spatial domain
    if (sol%idid > 0) then
        xout = (/(xa+i*(xb-xa)/(nout-1), i=0,nout-1)/)
        call ebacoli95_vals(sol, xout, uout)

        print '("At t = ",f7.2)', sol%t0
        write(*,'(/a)') 'the solution is'
        write(*,'(a13,a27)') 'XOUT', 'UOUT'
        do i = 1, nout
           ij = (i-1)*npde
           write(*,*) xout(i), (uout(ij+k), k = 1, npde)
        end do
    end if

    call ebacoli95_sol_teardown(sol)

end program