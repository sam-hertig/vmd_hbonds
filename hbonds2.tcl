# This script extracts coordinates of atoms forming an H-bond within selection for all the frames of the trajectory as separate XYZ (donor line, acceptor line, etc) files (one file for each entrance in the filelist). Useful for creation of hydrogen bonding maps.
# Andriy Anishkin (anishkin@icqmail.com) UMCP

#Set H-bond definition criteria
set cutoff 3.51
set angle 30.1


#Open file and load part of DCD trajectory
mol new ionized.psf type psf
mol off top
set first_frame 0
set last_frame 4000
set filelist {stride100.dcd}

#set filelist {test_wtr.dcd}

foreach crnt_file $filelist {
	#load file
	animate read dcd $crnt_file beg 0 end -1 waitfor all
#	animate read dcd $crnt_file beg 0 end $last_frame waitfor all
	sleep 5



	#Extract frames from file
	set num_steps [molinfo top get numframes]


	#Set selections to look for H-bonds
	set selection_donor [atomselect top "protein"]
# 	set selection_acceptor $selection_donor

	for {set frame 0} {$frame < $num_steps} {incr frame} {
		#Update the frame
		$selection_donor frame $frame
		$selection_donor update
# 		$selection_acceptor frame $frame
# 		$selection_acceptor update
		
		#Find H-bonds
# 		set hbonds_list [measure hbonds $cutoff $angle $selection_donor $selection_acceptor]
		set hbonds_list [measure hbonds $cutoff $angle $selection_donor]
		set donors_index [lindex $hbonds_list 0]
		set acceptors_index [lindex $hbonds_list 1]
		set hydrogens_index [lindex $hbonds_list 2]
		
		#Write results into file
		set filename salt_Hbd_[format "%04d" [expr {$frame + $first_frame}]].txt
		set filename_i i_salt_Hbd_[format "%04d" [expr {$frame + $first_frame}]].txt
		set donors_index_length [llength $donors_index]
		set fid [open $filename w]
		set fid_i [open $filename_i w]
		for {set i 0} {$i<$donors_index_length} {incr i} {
			
			#Get identification characteristics for current h-bond
			set donors_index_selection [atomselect top "index [lindex $donors_index $i]" frame $frame]
			set donors_index_x [$donors_index_selection get x]
			set donors_index_y [$donors_index_selection get y]
			set donors_index_z [$donors_index_selection get z]
			set donors_index_name [$donors_index_selection get name]
			set donors_index_resid [$donors_index_selection get resid]
			set donors_index_segname [$donors_index_selection get segname]
			
			set acceptors_index_selection [atomselect top "index [lindex $acceptors_index $i]" frame $frame]
			set acceptors_index_x [$acceptors_index_selection get x]
			set acceptors_index_y [$acceptors_index_selection get y]
			set acceptors_index_z [$acceptors_index_selection get z]
			set acceptors_index_name [$acceptors_index_selection get name]
			set acceptors_index_resid [$acceptors_index_selection get resid]
			set acceptors_index_segname [$acceptors_index_selection get segname]
			
			set hydrogens_index_selection [atomselect top "index [lindex $hydrogens_index $i]" frame $frame]
			set hydrogens_index_name [$hydrogens_index_selection get name]
			set hydrogens_index_resid [$hydrogens_index_selection get resid]
			set hydrogens_index_segname [$hydrogens_index_selection get segname]
			
		
			puts $fid "$donors_index_x\t$donors_index_y\t$donors_index_z"
			puts $fid "$acceptors_index_x\t$acceptors_index_y\t$acceptors_index_z"

			puts $fid_i "$donors_index_name\t$donors_index_resid\t$donors_index_segname\t$acceptors_index_name\t$acceptors_index_resid\t$acceptors_index_segname\t$hydrogens_index_name\t$hydrogens_index_resid\t$hydrogens_index_segname"
			
			$donors_index_selection delete
			$acceptors_index_selection delete
			$hydrogens_index_selection delete
		}
		puts $fid_i "$i"
		close $fid
		close $fid_i
		puts "global frame [expr {$frame + $first_frame}]     file $crnt_file       frame $frame of [expr {($num_steps - 1)}] finished"

	}
	set first_frame [expr {$first_frame + $num_steps}]
	animate delete all
}


bell
puts "Finished !!!"




