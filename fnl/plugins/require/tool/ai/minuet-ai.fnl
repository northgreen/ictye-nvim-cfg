{1 :milanglacier/minuet-ai.nvim
  :event :BufReadPre
  :opts {:provider :openai_fim_compatible
    :provider_options {:openai_fim_compatible {:api_key :DEEPSEEK_API_KEY
        :name :deepseek
        :optional {:max_tokens 256
          :top_p 0.9}}}
    :virtualtext {:auto_trigger_ft []
      :keymap {:accept :<A-A>
        :accept_line :<A-a>
        :accept_n_lines :<A-z>
        :prev "<A-[>"
        :next "<A-]>"
        :dismiss :<A-e>}}}}
