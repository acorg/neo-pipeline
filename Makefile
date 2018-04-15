.PHONY: x, run, clean-1, clean-2, clean-3

x:
	@echo "There is no default make target. Use 'make run' to run the SLURM pipeline."

run:
	slurm-pipeline.py --specification specification.json > status.json

status:
	slurm-pipeline-status.py --specification status.json

# Remove all large intermediate files. Only run this if you're sure you
# want to throw away all that work!
clean-1:
	rm -f \
              02-map/*-unmapped.fastq.gz \
              03-diamond/*.json.bz2

# Remove SLURM output files.
clean-2: clean-1
	rm -f \
              */slurm-*.out

# Remove *all* intermediates, including the final panel output.
clean-3: clean-2
	rm -fr \
               logs \
               02-map/*.sam \
               02-map/*.bam \
               04-panel/out \
               04-panel/summary-proteins \
               04-panel/summary-virus \
               slurm-pipeline.done \
               slurm-pipeline.running \
               status.json

clean-stats:
	rm -fr ../../../stats
