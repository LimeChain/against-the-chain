import logger from 'jet-logger';

import ENV from '@src/common/constants/ENV';
import { httpServer } from './server';


/******************************************************************************
                                  Run
******************************************************************************/

const SERVER_START_MSG = ('Express server started on port: ' + 
  ENV.Port.toString());

const port = process.env.PORT ?? 3000;

httpServer.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
