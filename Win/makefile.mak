#
# Tentative makefile for QuantLib under Borland C++
#

.autodepend

# Directories
OUTPUT_DIR		= .\Release
PYTHON_DIR		= ..\Python
SWIG_DIR		= ..\Swig
SOURCES_DIR		= ..\Sources
INCLUDE_DIR		= ..\Include
BCC_INCLUDE		= $(MAKEDIR)\..\include
BCC_LIBS		= $(MAKEDIR)\..\lib
PYTHON_INCLUDE	= "C:\Program Files\Python\include"
PYTHON_LIBS		= "C:\Program Files\Python\libs"

# Object files
CORE_OBJS		= $(OUTPUT_DIR)\calendar.obj $(OUTPUT_DIR)\date.obj $(OUTPUT_DIR)\solver1d.obj $(OUTPUT_DIR)\dataformatters.obj
CALENDAR_OBJS	= $(OUTPUT_DIR)\westerncalendar.obj $(OUTPUT_DIR)\frankfurt.obj $(OUTPUT_DIR)\london.obj $(OUTPUT_DIR)\milan.obj $(OUTPUT_DIR)\newyork.obj $(OUTPUT_DIR)\target.obj $(OUTPUT_DIR)\zurich.obj 
DAYCOUNT_OBJS	= $(OUTPUT_DIR)\actualactual.obj $(OUTPUT_DIR)\thirty360.obj $(OUTPUT_DIR)\thirty360italian.obj
MATH_OBJS		= $(OUTPUT_DIR)\normaldistribution.obj $(OUTPUT_DIR)\statistics.obj  $(OUTPUT_DIR)\newcubicspline.obj
FDM_OBJS		= $(OUTPUT_DIR)\tridiagonaloperator.obj $(OUTPUT_DIR)\bsmoperator.obj
PRICER_OBJS		= $(OUTPUT_DIR)\bsmoption.obj $(OUTPUT_DIR)\bsmnumericaloption.obj $(OUTPUT_DIR)\bsmeuropeanoption.obj $(OUTPUT_DIR)\bsmamericanoption.obj $(OUTPUT_DIR)\dividendamericanoption.obj 
SOLVER1D_OBJS	= $(OUTPUT_DIR)\bisection.obj $(OUTPUT_DIR)\brent.obj $(OUTPUT_DIR)\falseposition.obj $(OUTPUT_DIR)\newton.obj $(OUTPUT_DIR)\newtonsafe.obj $(OUTPUT_DIR)\ridder.obj $(OUTPUT_DIR)\secant.obj
TERMSTRUC_OBJS	= $(OUTPUT_DIR)\piecewiseconstantforwards.obj 
QUANTLIB_OBJS	= $(CORE_OBJS) $(CALENDAR_OBJS) $(DAYCOUNT_OBJS) $(MATH_OBJS) $(FDM_OBJS) $(PRICER_OBJS) $(SOLVER1D_OBJS) $(TERMSTRUC_OBJS) 
WIN_OBJS		= c0d32.obj 

# Libraries
WIN_LIBS 		= import32.lib cw32mt.lib
PYTHON_LIB		= $(PYTHON_LIBS)\python15.lib
PYTHON_BCC_LIB	= bccpython.lib

# Tools to be used
CC			= bcc32
LINK		= ilink32
COFF2OMF	= coff2omf
SWIG		= swig1.3a5
DOXYGEN		= doxygen
LATEX		= pdflatex
MAKEINDEX	= makeindex

# Options
CC_OPTS		= -q -c -tWM -n$(OUTPUT_DIR) -w-8027 \
	-I$(INCLUDE_DIR) \
	-I$(INCLUDE_DIR)\Calendars \
	-I$(INCLUDE_DIR)\Currencies \
	-I$(INCLUDE_DIR)\DayCounters \
	-I$(INCLUDE_DIR)\FiniteDifferences \
	-I$(INCLUDE_DIR)\Instruments \
	-I$(INCLUDE_DIR)\Math \
	-I$(INCLUDE_DIR)\Patterns \
	-I$(INCLUDE_DIR)\Pricers \
	-I$(INCLUDE_DIR)\Solvers1D \
	-I$(INCLUDE_DIR)\TermStructures \
	-I$(PYTHON_INCLUDE) \
	-I$(BCC_INCLUDE) 
LINK_OPTS	= -q -x -L$(BCC_LIBS)

# Generic rules
.cpp.obj:
    @$(CC) $(CC_OPTS) $<

# Primary target:
# QuantLib library
QuantLib: $(OUTPUT_DIR)\QuantLib.lib

# Python module
Python: $(PYTHON_DIR)\QuantLibc.dll

$(PYTHON_DIR)\QuantLibc.dll:: $(OUTPUT_DIR) $(OUTPUT_DIR)\quantlib_wrap.obj $(OUTPUT_DIR)\QuantLib.lib $(PYTHON_BCC_LIB)
	@echo Linking Python module...
	@$(LINK) $(LINK_OPTS) -Tpd $(OUTPUT_DIR)\quantlib_wrap.obj $(WIN_OBJS),$(PYTHON_DIR)\QuantLibc.dll,, $(OUTPUT_DIR)\QuantLib.lib $(PYTHON_BCC_LIB) $(WIN_LIBS), QuantLibc.def
	@del $(PYTHON_DIR)\QuantLibc.ilc
	@del $(PYTHON_DIR)\QuantLibc.ild
	@del $(PYTHON_DIR)\QuantLibc.ilf
	@del $(PYTHON_DIR)\QuantLibc.ils
	@del $(PYTHON_DIR)\QuantLibc.tds
	@echo Build completed

# make sure the output directory exists
$(OUTPUT_DIR):
	@if not exist $(OUTPUT_DIR) md $(OUTPUT_DIR)

# Python lib in OMF format
$(PYTHON_BCC_LIB):
	@$(COFF2OMF) -q $(PYTHON_LIB) $(PYTHON_BCC_LIB)

# Wrapper functions
$(OUTPUT_DIR)\quantlib_wrap.obj:: $(PYTHON_DIR)\quantlib_wrap.cpp
	@echo Compiling wrappers...
	@$(CC) $(CC_OPTS) -w-8057 -w-8004 -w-8060 -D__WIN32__ -DMSC_CORE_BC_EXT $(PYTHON_DIR)\quantlib_wrap.cpp
$(PYTHON_DIR)\quantlib_wrap.cpp:: $(SWIG_DIR)\QuantLib.i $(SWIG_DIR)\Date.i $(SWIG_DIR)\Calendars.i \
  $(SWIG_DIR)\DayCounters.i $(SWIG_DIR)\Currencies.i $(SWIG_DIR)\Financial.i $(SWIG_DIR)\Options.i \
  $(SWIG_DIR)\Instruments.i $(SWIG_DIR)\Operators.i $(SWIG_DIR)\Pricers.i $(SWIG_DIR)\Solvers1D.i \
  $(SWIG_DIR)\TermStructures.i $(SWIG_DIR)\Vectors.i $(SWIG_DIR)\BoundaryConditions.i $(SWIG_DIR)\Statistics.i
	@echo Generating wrappers...
	@$(SWIG) -python -c++ -shadow -keyword -opt -I$(SWIG_DIR) -o $(PYTHON_DIR)\quantlib_wrap.cpp $(SWIG_DIR)\QuantLib.i
	@copy .\QuantLib.py $(PYTHON_DIR)\QuantLib.py
	@del .\QuantLib.py

# QuantLib library
$(OUTPUT_DIR)\QuantLib.lib:: Core Calendars DayCounters FiniteDifferences Math Pricers Solvers1D TermStructures
	@if exist $(OUTPUT_DIR)\QuantLib.lib del $(OUTPUT_DIR)\QuantLib.lib
	@tlib $(OUTPUT_DIR)\QuantLib.lib /a $(QUANTLIB_OBJS)

# Core
Core: $(OUTPUT_DIR) $(CORE_OBJS)
$(OUTPUT_DIR)\calendar.obj: $(SOURCES_DIR)\calendar.cpp
$(OUTPUT_DIR)\dataformatters.obj: $(SOURCES_DIR)\dataformatters.cpp
$(OUTPUT_DIR)\date.obj: $(SOURCES_DIR)\date.cpp
$(OUTPUT_DIR)\solver1d.obj: $(SOURCES_DIR)\solver1d.cpp


# Calendars
Calendars: $(OUTPUT_DIR) $(CALENDAR_OBJS)
$(OUTPUT_DIR)\westerncalendar.obj: $(SOURCES_DIR)\Calendars\westerncalendar.cpp
$(OUTPUT_DIR)\frankfurt.obj: $(SOURCES_DIR)\Calendars\frankfurt.cpp
$(OUTPUT_DIR)\london.obj: $(SOURCES_DIR)\Calendars\london.cpp
$(OUTPUT_DIR)\milan.obj: $(SOURCES_DIR)\Calendars\milan.cpp
$(OUTPUT_DIR)\newyork.obj: $(SOURCES_DIR)\Calendars\newyork.cpp
$(OUTPUT_DIR)\target.obj: $(SOURCES_DIR)\Calendars\target.cpp
$(OUTPUT_DIR)\zurich.obj: $(SOURCES_DIR)\Calendars\zurich.cpp


# Day counters
DayCounters: $(OUTPUT_DIR) $(DAYCOUNT_OBJS)
$(OUTPUT_DIR)\actualactual.obj: $(SOURCES_DIR)\DayCounters\actualactual.cpp
$(OUTPUT_DIR)\thirty360.obj: $(SOURCES_DIR)\DayCounters\thirty360.cpp
$(OUTPUT_DIR)\thirty360italian.obj: $(SOURCES_DIR)\DayCounters\thirty360italian.cpp


# Finite difference methods
FiniteDifferences: $(OUTPUT_DIR) $(FDM_OBJS)
$(OUTPUT_DIR)\tridiagonaloperator.obj: $(SOURCES_DIR)\FiniteDifferences\tridiagonaloperator.cpp
$(OUTPUT_DIR)\bsmoperator.obj: $(SOURCES_DIR)\FiniteDifferences\bsmoperator.cpp


# Math
Math: $(OUTPUT_DIR) $(MATH_OBJS)
$(OUTPUT_DIR)\normaldistribution.obj: $(SOURCES_DIR)\Math\normaldistribution.cpp
$(OUTPUT_DIR)\statistics.obj: $(SOURCES_DIR)\Math\statistics.cpp
$(OUTPUT_DIR)\newcubicspline.obj: $(SOURCES_DIR)\Math\newcubicspline.cpp


# Pricers
Pricers: $(OUTPUT_DIR) $(PRICER_OBJS)
$(OUTPUT_DIR)\bsmoption.obj: $(SOURCES_DIR)\Pricers\bsmoption.cpp
$(OUTPUT_DIR)\bsmnumericaloption.obj: $(SOURCES_DIR)\Pricers\bsmnumericaloption.cpp
$(OUTPUT_DIR)\bsmeuropeanoption.obj: $(SOURCES_DIR)\Pricers\bsmeuropeanoption.cpp
$(OUTPUT_DIR)\bsmamericanoption.obj: $(SOURCES_DIR)\Pricers\bsmamericanoption.cpp
$(OUTPUT_DIR)\dividendamericanoption.obj: $(SOURCES_DIR)\Pricers\dividendamericanoption.cpp


# 1D solvers
Solvers1D: $(OUTPUT_DIR) $(SOLVER1D_OBJS)
$(OUTPUT_DIR)\bisection.obj: $(SOURCES_DIR)\Solvers1D\bisection.cpp
$(OUTPUT_DIR)\brent.obj: $(SOURCES_DIR)\Solvers1D\brent.cpp
$(OUTPUT_DIR)\falseposition.obj: $(SOURCES_DIR)\Solvers1D\falseposition.cpp
$(OUTPUT_DIR)\newton.obj: $(SOURCES_DIR)\Solvers1D\newton.cpp
$(OUTPUT_DIR)\newtonsafe.obj: $(SOURCES_DIR)\Solvers1D\newtonsafe.cpp
$(OUTPUT_DIR)\ridder.obj: $(SOURCES_DIR)\Solvers1D\ridder.cpp
$(OUTPUT_DIR)\secant.obj: $(SOURCES_DIR)\Solvers1D\secant.cpp


# Term structures
TermStructures: $(OUTPUT_DIR) $(TERMSTRUC_OBJS)
$(OUTPUT_DIR)\piecewiseconstantforwards.obj: $(SOURCES_DIR)\TermStructures\piecewiseconstantforwards.cpp


# Clean up
clean::
	@if exist $(PYTHON_DIR)\QuantLib.py       del $(PYTHON_DIR)\QuantLib.py
	@if exist $(PYTHON_DIR)\QuantLib.pyc      del $(PYTHON_DIR)\QuantLib.pyc
	@if exist $(PYTHON_DIR)\QuantLibc.dll     del $(PYTHON_DIR)\QuantLibc.dll
	@if exist $(PYTHON_DIR)\quantlib_wrap.cpp del $(PYTHON_DIR)\quantlib_wrap.cpp
	@if exist $(OUTPUT_DIR) rd /s /q $(OUTPUT_DIR)


# Documentation
Docs::
	@cd ..\Docs
	@$(DOXYGEN) doxygen.cfg
	@cd latex
	@$(LATEX) refman
	@$(MAKEINDEX) refman.idx
	@$(LATEX) refman
	@cd ..\..\Win
