SETTING_FILE := setting.json

GPG_ENCRYPT_KEY_ID := `cat $(SETTING_FILE) | jq -r '.encrypt_key_id'`
GPG_SIGN_KEY_ID := `cat $(SETTING_FILE) | jq -r '.sign_key_id'`
to := `cat $(SETTING_FILE) | jq -r '.default_restore_target'`

RUN_DUPLICITY := duplicity --use-agent --encrypt-key $(GPG_ENCRYPT_KEY_ID) --sign-key $(GPG_SIGN_KEY_ID)


.PHONY: list-backups
list-backups:
	@cat $(SETTING_FILE) \
		| jq -r '.backups | to_entries[] | "[\(.key)] \(.value.name) (\(.value.source))"'


.PHONY: select-backup
select-backup: list-backups
	$(eval BACKUP_INDEX ?= $(shell read -p "Select backup: " index; echo $${index}))

.PHONY: select-file-to-restore
select-file-to-restore: select-backup
	$(eval ITEM_TO_RESTORE ?= $(shell cat $(SETTING_FILE) \
		| jq -r '.backups[$(BACKUP_INDEX)]|" \
			$(RUN_DUPLICITY) -v0 list-current-files \"\(.target)\";"' \
		| sh | cut -c 26- | fzf))

.PHONY: backup
backup:
	@cat $(SETTING_FILE) \
		| jq -r '.backups[]|" \
			echo \"Backing up \(.name)...\n\"; \
			$(RUN_DUPLICITY) \"\(.source)\" \"\(.target)\";"' \
		| sh

.PHONY: backup-single
backup-single: select-backup
	@cat $(SETTING_FILE) \
		| jq -r '.backups[$(BACKUP_INDEX)]|" \
			echo \"Backing up \(.name)...\n\"; \
			$(RUN_DUPLICITY) \"\(.source)\" \"\(.target)\";"' \
		| sh

.PHONY: restore-file
restore-file: select-file-to-restore
	@mkdir -p '$(to)/$(shell dirname "$(ITEM_TO_RESTORE)")'
	@echo "\nRestoring $(ITEM_TO_RESTORE) to $(to)..."
	@cat $(SETTING_FILE) \
		| jq -r '.backups[$(BACKUP_INDEX)]|" \
			$(RUN_DUPLICITY) -v0 restore --file-to-restore \"$(ITEM_TO_RESTORE)\" \"\(.target)\" \"$(to)/$(ITEM_TO_RESTORE)\""' \
		| sh
	@echo "Done"

